require "mastodon"
require "json"

require "./tootsee/**"

module Tootsee
  # Configuration for the bot, e.g. the Mastodon URL and secret keys. These are
  # extracted from environment variables.
  alias Config = {
    masto_url: String,
    access_token: String,
    port: Int32,
    azure_url: String,
    azure_key: String,
  }

  def self.run
    # Load config from environment variables
    config = {
      masto_url: ENV["MASTO_URL"],
      access_token: ENV["ACCESS_TOKEN"],
      port: ENV["PORT"].to_i,
      azure_url: ENV["AZURE_URL"],
      azure_key: ENV["AZURE_KEY"],
    }

    # Create ports
    stream = Ports::MastodonStreamI.new(config)
    client = Ports::MastodonClientI.new(config)
    http_client = Ports::HTTPClientPortI.new

    # Create components
    listener = Listener.new(stream)
    replier = Replier.new(client)
    captioner = Captioner.new(http_client, config)

    # Let's go 🎉
    listener.listen do |mention|
      puts("Received mention: #{mention}")
      # TODO For now we hardcode a URL of a corgi doing a sploot. Eventually
      # this will be the URL from an image search.
      caption = captioner.caption("https://i.pinimg.com/736x/ca/fc/f3/cafcf316846261671d6a3944838c180d--corgi-mix-young-ones.jpg")
      puts("Caption: #{caption}")
      replier.reply(caption, mention)
    end
  end
end
