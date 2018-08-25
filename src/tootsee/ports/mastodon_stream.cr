module Tootsee
  module Ports
    # Incoming port from the Mastodon streaming client.
    abstract class MastodonStream
      # This does not return. It calls the block whenever the bot receives a
      # push notification from Mastodon.
      abstract def listen(&block : Mastodon::Entities::Notification -> Void)
    end

    # Actual implementation of the stream. In tests, use `MockMastodonStream`
    # instead.
    class MastodonStreamI < MastodonStream
      def initialize(@config : Config); end

      def listen(&block : Mastodon::Entities::Notification -> Void)
        # We must loop and rescue because the streaming client tends to crash 🤷‍
        loop do
          streaming_client = Mastodon::Streaming::Client.new(
            url: @config[:masto_url],
            access_token: @config[:access_token],
          )
          puts("Listening...")
          streaming_client.user do |obj|
            if obj.is_a?(Mastodon::Entities::Notification)
              yield obj
            end
          end
        rescue ex
          puts("Exception in listen loop: #{ex}")
        end
      end
    end
  end
end
