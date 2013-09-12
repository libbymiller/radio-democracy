require 'json'
require 'cgi'
require 'faye'
require 'rest-client'
require 'pp'

$:<< './lib'
require 'local_config'

class XMLWebAPI < Sinatra::Base
  register Sinatra::Async

  use Faye::RackAdapter, :mount => '/faye', :timeout => 25

  RestClient.proxy = ENV['HTTP_PROXY']

  def initialize(player, root)
    @player = player
    super()
  end

  options '/' do
      response.headers["Access-Control-Allow-Origin"] = "*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      halt 200
  end

  get '/uc/' do
      f = File.read("sample_xml/uc.xml")
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { f.to_s }
  end


  get '/uc/time' do
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      t = Time.now.getutc.strftime("%Y-%m-%dT%H:%M:%SZ")
      b = "<response resource=\"uc/time\">
  <time rcvdtime=\"#{t}\"
        replytime=\"#{t}\"/>
</response>
"
      body { b.to_s }
  end


# lists of sources of data - only on-demand in this case

  get '/uc/source-lists/uc_default' do
      resp = "<response resource='uc/source-lists/uc_default' 
<sources>"
      config = LocalConfig.new
      url_base = config.url_base.url

      resp << "\n  <source name='iPlayer podcasts' sid='iplayer' live='false' linear='false' follow-on='false' sref='#{url_base}items'/>"
      resp << "\n</sources>
</response>"

      response.headers['content-type'] = 'text/plain' 
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { resp.to_s }
  end

# same as above

  get '/uc/sources' do
      resp = "<response resource='uc/source-lists/uc_default' 
<sources>"
      config = LocalConfig.new
      url_base = config.url_base.url

      resp << "\n  <source name='iPlayer podcasts' sid='iplayer' live='false' linear='false' follow-on='false' sref='#{url_base}items'/>"
      resp << "\n</sources>
</response>"

      response.headers['content-type'] = 'text/plain' 
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { resp.to_s }
  end


# sort of now playing
#   server.mount( '/uc/outputs/0', OutputsMainServlet )

  get '/uc/outputs/0' do

      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"

      vol = @player.playlist.volume
      mute = "false"
      if(vol==0)
        mute == "true"
      end

      @player.state.inspect

      file = @player.playlist.tracks[0].file

      b = "<response resource=\"uc/outputs/0\">
  <output name='Main Audio'>
    <settings volume='#{vol}' mute='#{mute}' />
    <programme sid=\"BBCOne\" cid='#{file}' />
    <playback speed=\"1.0\"/>
  </output>
</response>
"
      body { b.to_s } #fixme @@
  end


# volume
#   server.mount( '/uc/outputs/0/settings', OutputsMainSettingsServlet )


  get '/uc/outputs/0/settings/:vol' do
      vol = params[:vol]
      puts "vol is #{vol}"
#      playlist = Radiodan::Playlist.new(volume: vol)
#      @player.playlist = playlist

      mute = "false"
      if(vol==0)
        mute ="true"
      end

      `mpc volume "#{vol}"` #fixme

      b = "<response resource=\"uc/outputs/0/settings\">
  <settings volume='#{vol}' mute='#{mute}' />
</response>
"
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { b.to_s } #fixme @@
  end



#   server.mount( '/uc/search/global-content-id/', PlayCridServlet )
#   play the programme

  get '/uc/search/global-content-id/:id' do
      id = params[:id]
      puts "id is #{id}"
      playlist = Radiodan::Playlist.new(tracks: id, volume: @player.playlist.volume)
      @player.playlist = playlist
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { "<reponse>#{:id}</response>" } #fixme @@
  end


## list of outputs

# uc/search/source-lists/uc_default

  get '/uc/search/source-lists/uc_default' do

      text = "<response resource='uc/search/source-lists/uc_default'>
"

      f = File.readlines("items")

      f.each do |line| # need more metadata
        arr = line.split(" ")
        service = "service"
        pid = arr[0]
        start = "start"
        en = "end"
        title = arr[0]
        text << "
<results more=\"true\">
  <content sid=\"#{service}\" cid=\"#{pid}\" global-content-id=\"#{pid}\"
title=\"#{title}\" interactive=\"false\" start=\"#{start}\" acquirable-until=\"#{start}\"
presentable-from=\"#{start}\" presentable-until=\"#{en}\">
    <synopsis>
#{title}
    </synopsis>
  </content>
</results>
"
      end
      text << "</response>
"

      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { text } 
  end

## buttons

  get '/try' do
      @player.trigger_event :random_channel
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      body { "<response>random</response>" }
  end

  get '/down' do
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"
      config = LocalConfig.new
      url_base = config.url_base.url
      url = "#{url_base}/down/"
      req = RestClient.post(url, :item => @player.playlist.tracks[0].file)

      @player.playlist = Radiodan::Playlist.new()

      begin
         `espeak -v en "Down vote registered"`
      rescue
      end

      @player.trigger_event :best_new_channel

      status req.code

      if(req.code==201)
        body {"<response>OK</response>"}      
      else
        body {"<response>NOK</response>"}      
      end
  end

  get '/up' do
      response.headers['content-type'] = 'text/plain' #is this right?
      response.headers["Access-Control-Allow-Origin"]="*"
      response.headers["Access-Control-Allow-Methods"] = "GET, POST"
      response.headers["Access-Control-Allow-Headers"]="X-Requested-With, Origin"
      response.headers["Access-Control-Max-Age"]="86400"

      begin
         `espeak -v en "Up vote registered"`
      rescue
      end

      config = LocalConfig.new
      url_base = config.url_base.url    
      url = "#{url_base}/up/"
      req = RestClient.post(url, :item => @player.playlist.tracks[0].file)    
      status req.code
      if(req.code==201)
        body {"<response>OK</response>"}      
      else
        body {"<response>NOK</response>"}      
      end
  end


end


