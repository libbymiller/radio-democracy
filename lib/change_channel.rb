class ChangeChannel
  include Radiodan::Logging

  def initialize(config)
    @filename = config[:filename]
  end

  def call(player)
    @player = player

    @player.register_event :change_channel do
      change_channel!
    end
  end

  def change_channel!
        channels = []
        items = File.readlines(@filename)
        items.each do |item|
          channels.push(item.split(" ")[0])
        end
        url = channels.sample

        puts "url is #{url}"
        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        playlist = Radiodan::Playlist.new(tracks: url, volume: @player.playlist.volume)
        @player.playlist = playlist

  end
end

