require "mastodon"

require "./tootsee/**"

module Tootsee
  # Configuration for the bot, e.g. the Mastodon URL and secret keys. These are
  # extracted from environment variables.
  alias Config = {
    masto_url: String,
    access_token: String,
    port: Int32,
  }

  def self.run
    # Load config from environment variables
    config = {
      masto_url: ENV["MASTO_URL"],
      access_token: ENV["ACCESS_TOKEN"],
      port: ENV["PORT"].to_i,
    }

    # Create ports
    stream = Ports::MastodonStreamI.new(config)
    client = Ports::MastodonClientI.new(config)

    # Create components
    listener = Listener.new(stream)
    replier = Replier.new(client)
    
    # Let's go 🎉
    listener.listen do |mention|
      puts("Received mention: #{mention}")
      replier.reply("hi :3", mention)
    end
  end
end
