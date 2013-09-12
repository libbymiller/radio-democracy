require 'local_config'
require "rest-client"
require 'pp'

class BestNewChannel
  include Radiodan::Logging

  def initialize(config)
    @filename = config[:filename]
    @metadata = config[:metadata]
  end

  def call(player)
    @player = player

    @player.register_event :play_state do |state|
      if(state == :stop)
        puts "state is stop"
#        foo_new_channel!
      else
        puts "state is not stop"
      end
    end
    @player.register_event :best_new_channel do
      best_new_channel!
#        foo_new_channel!
    end
  end
=begin
  def foo_new_channel!
        channels = []
        items = File.readlines(@filename)
        items.each do |item|
          channels.push(item.split(" ")[0])
        end
        url = channels.sample

        puts "url is #{url}..."
        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        playlist = Radiodan::Playlist.new(tracks: url, volume: @player.playlist.volume)
        @player.playlist = playlist

  end
=end
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
#        puts "local_candidates"
#        pp local_candidates

        local_candidates = local_candidates.sort_by {rand} #else when everythng's 0, it's alphabetical
#        puts "local_candidates 2"
#        pp local_candidates

        local_candidates = local_candidates.sort_by {|_key, value| value} #not reversed this time - least listened to

#        puts "remote_candidates"
#        pp listenables

        channels = []
        local_candidates.each do |c|
          channels.push(c[0])
        end

        urls = channels & listenables
#        puts "urls"
#        pp urls
        if(urls.length==0) #only happens when no remote service
          urls = channels
        end

        metadata = {}

        f = File.readlines(@metadata)

        f.each do |line|
          arr = line.split(" ")
          file = arr[0]
          channel = arr[1]
          title = arr.slice(2,arr.length).join(" ").chomp
          c = channel.gsub("_", " ")
          metadata[file]={"title"=>title, "channel"=>c}
        end



        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        vol = @player.playlist.volume
        @player.playlist = Radiodan::Playlist.new()

        url = urls[0].chomp
        begin
         `espeak -v en "Most popular channel chosen: #{metadata[url]["channel"]}"`
        rescue Exception=>e
          puts "barf"
          puts e
        end

        @player.playlist = Radiodan::Playlist.new(tracks: url, volume: vol)
  end
end

