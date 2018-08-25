module Tootsee
  module Ports
    # Outgoing port to the Mastodon client.
    abstract class MastodonClient
      # Send a toot in reply to the given toot ID.
      abstract def toot(
        text : String,
        in_reply_to_id : String?,
        spoiler_text : String,
        visibility : String,
      )
    end

    # Actual implementation of the client. In tests, use `MockMastodonClient`
    # instead.
    class MastodonClientI < MastodonClient
      def initialize(@config : Config)
        @client = Mastodon::REST::Client.new(
          url: @config[:masto_url],
          access_token: @config[:access_token],
        )
      end

      def toot(
        text : String,
        in_reply_to_id : String?,
        spoiler_text : String,
        visibility : String,
      )
        @client.create_status(
          text,
          in_reply_to_id: in_reply_to_id,
          spoiler_text: spoiler_text,
          visibility: visibility,
        )
      end
    end
  end
end
