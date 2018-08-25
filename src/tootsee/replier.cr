module Tootsee
  # Sends reply toots.
  class Replier
    def initialize(@client : Ports::MastodonClient); end

    # Send the given text in reply to the given mention.
    def reply(text : String, in_reply_to : Mention)
    end
  end
end
