require "../../spec_helper"

module Tootsee
  describe Listener do
    describe "#listen" do
      it "yields for each mention" do
        mention1 = FakeEntities.fake_mention
        mention1.status.not_nil!.id = "s1"
        mention1.status.not_nil!.content = "toot 1"
        mention1.status.not_nil!.spoiler_text = "spoiler 1"

        mention2 = FakeEntities.fake_mention
        mention2.status.not_nil!.id = "s2"
        mention2.status.not_nil!.content = "toot 2"
        mention2.status.not_nil!.visibility = "unlisted"

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
            })
          when 1
            mention.should eq({
              text: "toot 2",
              id: "s2",
              visibility: "unlisted",
              spoiler_text: "",
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

      it "strips HTML from the mention" do
        mention = FakeEntities.fake_mention
        mention.status.not_nil!.content = "<p><!-- blah -->Hello<br /> world</p>."
        notifs = [mention]
        stream = MockMastodonStream.new(notifs)

        Tootsee::Listener.new(stream).listen do |mention|
          mention[:text].should eq "Hello world."
        end
      end

      it "strips @mentions from the mention" do
        mention = FakeEntities.fake_mention
        mention.status.not_nil!.content = "<a>@<span>hobob</span></a> foo"
        notifs = [mention]
        stream = MockMastodonStream.new(notifs)

        Tootsee::Listener.new(stream).listen do |mention|
          mention[:text].should eq " foo"
        end
      end
    end
  end
end
