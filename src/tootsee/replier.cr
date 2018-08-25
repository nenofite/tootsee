module Tootsee
  # Sends reply toots.
  class Replier
    def initialize(@client : Ports::MastodonClient); end

    # Send the given text in reply to the given mention.
    def reply(text : String, in_reply_to : Listener::Mention)
      # Send a reply
      @client.toot(text, in_reply_to[:id])
    end
  end
end
