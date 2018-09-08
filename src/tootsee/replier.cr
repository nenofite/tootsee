module Tootsee
  # Sends reply toots.
  class Replier
    def initialize(@client : Ports::MastodonClient); end

    # Send the given text in reply to the given mention.
    def reply(text : String, in_reply_to : Listener::Mention)
      # Send a reply
      reply_text = "@#{in_reply_to[:full_user]} #{text}"

      begin
        @client.toot(
          text: reply_text,
          in_reply_to_id: in_reply_to[:id],
          spoiler_text: in_reply_to[:spoiler_text],
          visibility: in_reply_to[:visibility],
        )  
      rescue ex : JSON::MappingError | JSON::ParseException
        puts("Exception found for JSON parsing. Disregarding...")
      end
    end
  end
end
