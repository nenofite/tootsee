module Tootsee
  module Ports
    abstract class MastodonStream
      abstract def listen(&block : Mastodon::Entities::Notification -> Void)
    end
  end
end
