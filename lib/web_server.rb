require 'json'
require 'cgi'
require 'faye'

class WebServer < Sinatra::Base
  register Sinatra::Async

  use Faye::RackAdapter, :mount => '/faye', :timeout => 25

  def initialize(player)
    @player = player
    Faye::WebSocket.load_adapter('thin')
    client = Faye::Client.new("http://localhost:3000/faye")
    @player.register_event :oh_ffs do |pl|
      puts "playlist changed!!!!!!!!!!!!!!!!!!!!!!!!!! "
      p pl
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
