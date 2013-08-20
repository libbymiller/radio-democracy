require 'json'
require 'cgi'
require 'faye'
require 'pp'

class WebServer < Sinatra::Base
  register Sinatra::Async

  use Faye::RackAdapter, :mount => '/faye', :timeout => 25

  def initialize(player, root)
    @player = player
    Faye::WebSocket.load_adapter('thin')
    client = Faye::Client.new("http://localhost:3000/faye")

    @player.register_event :oh_ffs do |pl|
      puts "playlist changed"
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

  aget '/panic' do
    @player.trigger_event :panic
    body "Panic!"
  end

  aget '/change' do
    EM::Synchrony.next_tick do
      @player.trigger_event :change_channel
      body "Changing channel" # note that inspecting at this point doesn't work
    end
  end

  get '/test' do
    erb :test
  end

end
