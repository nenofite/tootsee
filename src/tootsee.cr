require "mastodon"
require "http/server"

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

    spawn do
      run_http_server(config)
    end

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

  def self.run_http_server(config : Config)
    # Put up a basic HTTP server to satisfy Heroku. If we don't do this, Heroku
    # assumes the app failed to start and kills it.
    server = HTTP::Server.new([
      HTTP::LogHandler.new,
      HTTP::ErrorHandler.new,
    ]) do |context|
      context.response.content_type = "text/plain"
      context.response.print("hello :3")
    end

    port = config[:port]
    puts("Listening for HTTP requests on #{port}")
    server.bind_tcp(port)
    server.listen
  end
end
