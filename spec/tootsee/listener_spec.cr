require "../../spec_helper"

module Tootsee
  describe Listener do
    describe "#listen" do
      it "yields for each mention" do
        mention1 = FakeEntities.fake_mention
        status1 = mention1.status.not_nil!
        status1.id = "s1"
        status1.content = "toot 1"
        status1.spoiler_text = "spoiler 1"
        status1.account.acct = "test@test.instance"

        mention2 = FakeEntities.fake_mention
        status2 = mention2.status.not_nil!
        status2.id = "s2"
        status2.content = "toot 2"
        status2.visibility = "unlisted"
        status2.account.acct = "friend@fake.instance"

        notifs = [mention1, mention2]
        stream = MockMastodonStream.new(notifs)

        called = 0
        Tootsee::Listener.new(stream).listen do |mention|
          case called
          when 0
            mention.should eq({
              text: "toot 1",
              id: "s1",
              visibility: "public",
              spoiler_text: "spoiler 1",
              full_user: "test@test.instance",
            })
          when 1
            mention.should eq({
              text: "toot 2",
              id: "s2",
              visibility: "unlisted",
              spoiler_text: "",
              full_user: "friend@fake.instance",
            })
          end
          called += 1
        end
        called.should eq 2
      end

      it "discards non-mentions" do
        notifs = [
          FakeEntities.fake_mention,
          FakeEntities.fake_follow,
          FakeEntities.fake_mention,
        ]
        stream = MockMastodonStream.new(notifs)

        called = 0
        Tootsee::Listener.new(stream).listen do |mention|
          called += 1
        end
        called.should eq 2
      end

      it "strips HTML and @mentions then normalizes whitespace" do
        mention = FakeEntities.fake_mention
        mention.status.not_nil!.content = "<p><!-- blah -->Hello<br /> <a>@<span>hobob</span></a> \nworld</p>.    "
        notifs = [mention]
        stream = MockMastodonStream.new(notifs)

        Tootsee::Listener.new(stream).listen do |mention|
          mention[:text].should eq "Hello world."
        end
      end
    end
  end
end
