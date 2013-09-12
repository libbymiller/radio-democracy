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
        config = LocalConfig.new
        url = config.url_base.url
        candidates = {}
        begin
          req = RestClient.get(url)
          req.body.split("\n").each do |item|
            thing = item.split(" ")
            name = thing[0]
            up = thing[1] ? thing[1].to_i : 0
            down = thing[2] ? thing[2].to_i : 0
            diff = up - down
            candidates[name]=diff
          end
        rescue Exception=>e
          puts "barf with #{e} for #{url}"
        end
        candidates = candidates.sort_by {|_key, value| value}.reverse

        # remote things
        listenables = []
        candidates.each do |c|
          listenables.push(c[0])
        end

        # local things
        local_candidates = {}
        File.readlines(@filename).each do |item|
          thing = item.split(" ")
          name = thing[0]
          listens = thing[1] ? thing[1].to_i : 0
          local_candidates[name] = listens
        end
        puts "local_candidates"
        pp local_candidates

        local_candidates = local_candidates.sort_by {rand} #else when everythng's 0, it's alphabetical
        puts "local_candidates 2"
        pp local_candidates

        local_candidates = local_candidates.sort_by {|_key, value| value} #not reversed this time - least listened to

        puts "remote_candidates"
        pp listenables

        channels = []
        local_candidates.each do |c|
          channels.push(c[0])
        end

        urls = channels & listenables
        puts "urls"
        pp urls
        if(urls.length==0) #only happens when no remote service
          urls = channels
        end

        logger.debug "changing to #{urls[0]}, #{@player.playlist.volume}..."
        playlist = Radiodan::Playlist.new(tracks: urls[0], volume: @player.playlist.volume)
        @player.playlist = playlist
  end
end

