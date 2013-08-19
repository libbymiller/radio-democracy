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

    EM.defer \
      proc {
        url = @filename
        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        playlist = Radiodan::Playlist.new(tracks: url, volume: @player.playlist.volume)
        @player.playlist = playlist
        @player.trigger_event(:channel_changed)
      },
      proc {
      }

  end
end

