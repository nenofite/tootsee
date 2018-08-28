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

  # A fake HTTP client. Collects all requests in an array that can be asserted
  # against. Gives responses based on the given block.
  class MockHTTPClientPort < Tootsee::Ports::HTTPClientPort
    alias Params = {
      method: String,
      url: String | URI,
      headers: HTTP::Headers?,
      body: HTTP::Client::BodyType,
    }

    getter calls

    def initialize(&block : -> HTTP::Client::Response)
      @get_response = block
      @calls = [] of Params
    end

    def exec(
      method : String,
      url : String | URI,
      headers : HTTP::Headers? = nil,
      body : HTTP::Client::BodyType = nil,
    ) : HTTP::Client::Response
      params = {
        method: method,
        url: url,
        headers: headers,
        body: body,
      }
      @calls << params
      @get_response.call
    end
  end
end
