require "mastodon"
require "http/server"
require "json"

require "./tootsee/**"

module Tootsee
  extend self

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

  def run
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
        attempt_to("reply to #{mention.id}") do
          image = imager.image(mention[:text])
          puts("Image: #{image}")
          caption = captioner.caption(image)
          puts("Caption: #{caption}")
          replier.reply(caption, mention)
        end
      end
    end
  end

  def run_http_server(config : Config)
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

  # Execute the task until it does not raise an exception.
  # 1. Run the task immediately.
  # 2. If it fails, log the error and that it is retrying.
  # 3. Sleep for a short time.
  # 4. Retry the task.
  # 5. If it fails, repeat from step 2 up to `times` times.
  def attempt_to(task : String, *, times : Int32 = 4, &block)
    attempt = 1
    next_sleep = 300.milliseconds
    while attempt < times
      begin
        yield
        return
      rescue ex
        STDERR.puts("In attempt #{attempt} to #{task}:")
        ex.inspect_with_backtrace(STDERR)
      end
      attempt += 1
      STDERR.puts("Attempt #{attempt}/#{times} to #{task}. Sleeping for #{next_sleep}")
      sleep(next_sleep)
      next_sleep *= 10
    end
    # On the final attempt, don't rescue
    yield
  end
end
