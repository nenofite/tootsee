require "mastodon"
require "http/server"
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

  class TootseeException < Exception; end

  def self.run
    # Load config from environment variables
    config = {
      masto_url: ENV["MASTO_URL"],
      access_token: ENV["ACCESS_TOKEN"],
      port: ENV["PORT"].to_i,
      azure_url: ENV["AZURE_URL"],
      azure_key: ENV["AZURE_KEY"],
    }

    spawn do
      run_http_server(config)
    end

    # Create ports
    stream = Ports::MastodonStreamI.new(config)
    client = Ports::MastodonClientI.new(config)
    http_client = Ports::HTTPClientPortI.new

    # Create components
    listener = Listener.new(stream)
    replier = Replier.new(client)
    captioner = Captioner.new(http_client, config)
    imager = Imager.new(http_client)

    # Let's go 🎉
    listener.listen do |mention|
      spawn do
        puts("Received mention: #{mention}")
        image = imager.image(mention[:text])
        puts("Image: #{image}")
        caption = captioner.caption(image)
        puts("Caption: #{caption}")
        replier.reply(caption, mention)
      end
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
    server.listen("0.0.0.0", port)
  end
end
