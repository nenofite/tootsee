require "spec"
require "../src/tootsee"

class MockMastodonStream < Tootsee::Ports::MastodonStream
  def initialize(@notifs : Array(Mastodon::Entities::Notification)); end

  def listen(&block : Mastodon::Entities::Notification -> Void)
    @notifs.each do |notif|
      yield notif
    end
  end
end

def fake_account
  Mastodon::Entities::Account.from_json(<<-JSON
    {
      "id": "1",
      "username": "USER",
      "acct": "ACCOUNT",
      "display_name": "DISPLAY_NAME",
      "locked": false,
      "created_at": "2017-04-14T06:05:55",
      "followers_count": 1,
      "following_count": 1,
      "statuses_count": 1,
      "note": "",
      "url": "https://example.com/@USER",
      "avatar": "https://example.com/avatars/original/missing.png",
      "avatar_static": "https://example.com/avatars/original/missing.png",
      "header": "https://example.com/headers/original/missing.png",
      "header_static": "https://example.com/headers/original/missing.png"
    }
  JSON
  )
end

def fake_status
  Mastodon::Entities::Status.from_json(<<-JSON
    {
      "account": #{fake_account.to_json},
      "content": "<p>Hello world.</p>",
      "created_at": "2017-04-14T08:48:15",
      "favourites_count": 1,
      "id": "14513",
      "media_attachments": [],
      "mentions": [],
      "reblogs_count": 1,
      "sensitive": false,
      "spoiler_text": "",
      "tags": [],
      "uri": "tag:example.com,2017-04-14:objectId=14513:objectType=Status",
      "url": "https://example.com/@USER/14513",
      "visibility": "public",
      "language": ""
    }
    JSON
  )
end

def fake_mention
  Mastodon::Entities::Notification.from_json(<<-JSON
    {
      "account": #{fake_account.to_json},
      "created_at": "2017-04-14T08:48:47",
      "id": "2",
      "status": #{fake_status.to_json},
      "type": "mention"
    }
    JSON
  )
end
