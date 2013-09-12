class RandomChannel
  include Radiodan::Logging

  def initialize(config)
    @filename = config[:filename]
    @metadata = config[:metadata]
  end

  def call(player)
    @player = player

    @player.register_event :random_channel do
      random_channel!
    end
  end

  def random_channel!
        channels = []
        items = File.readlines(@filename)
        items.each do |item|
          channels.push(item.split(" ")[0])
        end
        url = channels.sample

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

#        @player.playlist = Radiodan::Playlist.new()

        begin
         `espeak -v en "Random channel chosen: #{metadata[url]["channel"]}"`
        rescue
        end

        puts "url is #{url}"
        logger.debug "changing to #{url}, #{@player.playlist.volume}..."
        vol = @player.playlist.volume
        @player.playlist = Radiodan::Playlist.new(tracks: url, volume: vol)

  end
end

