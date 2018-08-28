# Mock versions of the ports used for testing.
module MockPorts
  # A fake Mastodon port for testing. The listen block yields each of the given
  # notifications then returns.
  class MockMastodonStream < Tootsee::Ports::MastodonStream
    def initialize(@notifs : Array(Mastodon::Entities::Notification)); end

    def listen(&block : Mastodon::Entities::Notification -> Void)
      @notifs.each do |notif|
        yield notif
      end
    end
  end

  # A fake Mastodon port for testing. Collects all outgoing toots in an array that
  # can be asserted against.
  class MockMastodonClient < Tootsee::Ports::MastodonClient
    getter toots

    alias Toot = {
      text: String,
      in_reply_to_id: String?,
      spoiler_text: String,
      visibility: String,
    }

    def initialize
      @toots = [] of Toot
    end

    def toot(
      text : String,
      in_reply_to_id : String?,
      spoiler_text : String,
      visibility : String,
    )
      @toots << {
        text: text,
        in_reply_to_id: in_reply_to_id,
        spoiler_text: spoiler_text,
        visibility: visibility,
      }
    end
  end
end
