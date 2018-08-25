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
    config = {
      masto_url: ENV["MASTO_URL"],
      access_token: ENV["ACCESS_TOKEN"],
      port: ENV["PORT"].to_i,
    }
    stream = Ports::MastodonStreamI.new(config)
    listener = Listener.new(stream)
    listener.listen do |notif|
      puts(notif)
    end
  end
end
