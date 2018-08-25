module Tootsee
  module Ports
    abstract class MastodonStream
      abstract def listen(&block : Mastodon::Entities::Notification -> Void)
    end

    class MastodonStreamI < MastodonStream
      def initialize(@config : Config); end

      def listen(&block : Mastodon::Entities::Notification -> Void)
        loop do
          streaming_client = Mastodon::Streaming::Client.new(
            url: @config[:masto_url],
            access_token: @config[:access_token],
          )
          puts("Listening...")
          streaming_client.user do |obj|
            if obj.is_a?(Mastodon::Entities::Notification)
              if status = obj.status
                puts("Stream got: #{status.content}")
              end
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
