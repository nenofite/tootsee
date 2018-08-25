module Tootsee
  module Ports
    # Outgoing port to the Mastodon client.
    abstract class MastodonClient
      # Send a toot in reply to the given toot ID.
      abstract def toot(text : String, in_reply_to_id : String?)
    end

    # Actual implementation of the client. In tests, use `MockMastodonClient`
    # instead.
    class MastodonClientI < MastodonClient
      def initialize(@config : Config); end

      def toot(text : String, in_reply_to_id : String?)
        # TODO
      end
    end
  end
end
