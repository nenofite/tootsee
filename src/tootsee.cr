require "mastodon"

require "./tootsee/*"

module Tootsee
  # Configuration for the bot, e.g. the Mastodon URL and secret keys. These are
  # extracted from environment variables.
  alias Config = {
    masto_url: String,
    access_token: String,
    port: Int32,
  }

  class Main
    @masto_url: String = ENV["MASTO_URL"]
    @access_token: String = ENV["ACCESS_TOKEN"]
    @port: Int32 = ENV["PORT"].to_i

    @client = Mastodon::REST::Client.new(url: @masto_url, access_token: @access_token)
    @streaming_client = Mastodon::Streaming::Client.new(url: @masto_url, access_token: @access_token)

    def send_toot
      puts "Sending toot..."
      result = @client.create_status("test toot!", visibility: "private")
      puts result
    end

    # Subscribe to push notifications and listen for mentions. This does not
    # return.
    def listen
      puts("Listening for notifications")
      @streaming_client.user do |notification|
        puts(notification)
        if notification.is_a?(Mastodon::Entities::Notification) &&
            notification.type == "mention"
          handle_mention(notification)
        end
      end
    end

    private def handle_mention(notification)
      status = notification.status
      return unless notification.type == "mention" && status
      puts status.content
      # message = "ah yes, #{status.content}"
      # @client.create_status(message, in_reply_to_id: status.id)
    end
  end

  def self.run
    loop do
      Main.new.listen
    rescue ex
      puts("Exception in listen loop: #{ex}")
    end
  end
end

# Tootsee.run
