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
      full_user: String, # including the instance, e.g. @tootsee@botsin.space
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
          visibility: status.visibility,
          spoiler_text: status.spoiler_text,
          full_user: status.account.acct,
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
