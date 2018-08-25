module Tootsee
  # Streams notifications from Mastodon and filters down to incoming mentions.
  # Also extracts only the text from these mentions, discarding HTML.
  class Listener
    # A simplified mention toot, containing only the relevant information. HTML
    # is stripped from the toot contents.
    alias Mention = {
      text: String,
      id: String,
      visibility: String,
      spoiler_text: String,
    }

    def initialize(@stream : Ports::MastodonStream); end

    # Listen for incoming mentions. This does not return.
    def listen(&block : Mention -> Void)
      @stream.listen do |notif|
        next unless notif.type == "mention"
        next unless status = notif.status
        mention = {
          text: Listener.strip_html(status.content),
          id: status.id,
        }
        yield mention
      end
    end

    def self.strip_html(str : String) : String
      str
        # Strip tags
        .gsub(/<[^>]+>/, "")
        # Strip mentions
        .gsub(/@[^\s]+/, "")
    end
  end
end
