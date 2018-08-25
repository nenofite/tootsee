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
