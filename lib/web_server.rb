require 'json'
require 'cgi'
require 'faye'
require 'pp'
require "rest-client"

$:<< './lib'
require 'local_config'

class WebServer < Sinatra::Base
  register Sinatra::Async

  use Faye::RackAdapter, :mount => '/faye', :timeout => 25

  RestClient.proxy = ENV['HTTP_PROXY']

  def initialize(player, root)
    @player = player
    Faye::WebSocket.load_adapter('thin')
    client = Faye::Client.new("http://localhost:3000/faye")

    @player.register_event :playlist_changed do |pl|
      puts "playlist changed!!!!!!!!!!!!"
      p pl
      item = pl.tracks[0].file
      items = {}
      file_changed = false
      File.readlines(File.join(root, 'items')).each do |line|
        arr = line.split(" ")
        pp arr
        name = arr[0] 
        listened = arr[1]
        listened = listened ? listened.chomp.to_i : 0
        if(name && name!="")
          if(item == name)
            listened = listened + 1
            puts "name is ..#{name},, listened is #{listened}"
            file_changed = true
          end
          items[name] = listened
        end
      end

      if(file_changed)
        items_string = ""
        items.each do |k,v|
          items_string << k
          items_string << " "
          items_string << "#{v}"
          items_string << "\n"
        end
        File.open(File.join(root, 'items'), 'w') {|f| f.write(items_string) } 
      end     
      client.publish("/foo", "Playlist Changed: #{pl.inspect}")
    end
    super()
  end

  aget '/' do
    EM::Synchrony.next_tick do
      body { "<h1>Radiodan</h1><p>#{CGI.escapeHTML(@player.state.inspect)}</p>" }
    end
  end

  apost '/try' do
    EM::Synchrony.next_tick do
      @player.trigger_event :random_channel
      body "Random channel" # note that inspecting at this point doesn't work
    end
  end

  apost '/up' do
    EM::Synchrony.next_tick do
      config = LocalConfig.new
      url_base = config.url_base.url    
      url = "#{url_base}/up/"
      req = RestClient.post(url, :item => @player.playlist.tracks[0].file)    
      status req.code
      if(req.code==201)
        body {"OK"}      
      else
        body {"NOK"}
      end
    end
  end

  apost '/down' do
    EM::Synchrony.next_tick do
      config = LocalConfig.new
      url_base = config.url_base.url    
      url = "#{url_base}/down/"
      req = RestClient.post(url, :item => @player.playlist.tracks[0].file)    

      @player.trigger_event :best_new_channel

      status req.code
      if(req.code==201)
        body {"OK"}      
      else
        body {"NOK"}
      end
    end
  end

end


