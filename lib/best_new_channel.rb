require 'local_config'
require "rest-client"
require 'pp'

class BestNewChannel
  include Radiodan::Logging

  def initialize(config)
    @filename = config[:filename]
  end

  def call(player)
    @player = player

    @player.register_event :best_new_channel do
      best_new_channel!
    end
    @player.register_event :play_state do |state|
      if(state == :stop)
        puts "state is stop"
        best_new_channel!
      else
        puts "state is not stop"
      end
    end
  end

  def best_new_channel!
    EM.defer \
      proc {
        config = LocalConfig.new
        url = config.url_base.url
#        url = "http://dev.notu.be/2013/08/radio-democracy/"
        req = RestClient.get(url)
        candidates = {}
        req.body.split("\n").each do |item|
          thing = item.split(" ")
          name = thing[0]
          up = thing[1] ? thing[1].to_i : 0
          down = thing[2] ? thing[2].to_i : 0
          diff = up - down
          candidates[name]=diff
        end
        candidates = candidates.sort_by {|_key, value| value}.reverse

        puts "====candidates======"
        pp candidates

        listenables = []
        candidates.each do |c|
          listenables.push(c[0])
        end
        puts "====listenables======"

        pp listenables

        local_candidates = {}
        File.readlines(@filename).each do |item|
          thing = item.split(" ")
          name = thing[0]
          listens = thing[1] ? thing[1].to_i : 0
          local_candidates[name] = listens
        end
        local_candidates = local_candidates.sort_by {|_key, value| value} #not reverseed this time - least listened to

        channels = []
        local_candidates.each do |c|
          channels.push(c[0])
        end

=begin
        items = File.readlines(@filename)
        items.each do |item|
          arr = item.split(" ")
          name = arr[0]          
          views = arr[1]          
          if(!views || views && views.to_i==0)
            channels.push(name)
          end
        end

=end
        puts "====channels======"
        pp channels

        urls = listenables & channels
        puts "====urls======"
        pp urls

        puts "url is #{urls[0]}"
        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        playlist = Radiodan::Playlist.new(tracks: urls[0], volume: @player.playlist.volume)
        @player.playlist = playlist
      },
      proc {
#        @player.trigger_event(:channel_changed)
      }
  end
end

#b = BestNewChannel::new({:filename=>"../items"})
#pp b.best_new_channel!
