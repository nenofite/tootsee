require "spec"
require "../src/tootsee"
require "./fake_entities"

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

  alias Toot = {String, String?}

  def initialize
    @toots = [] of Toot
  end

  def toot(text : String, in_reply_to_id : String?)
    @toots << {text, in_reply_to_id}
  end
end
