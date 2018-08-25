require "../../spec_helper"

module Tootsee
  describe Listener do
    describe "#listen" do
      it "yields for each mention" do
        notifs = [
          FakeEntities.fake_mention,
          FakeEntities.fake_mention,
          FakeEntities.fake_mention,
        ]
        stream = MockMastodonStream.new(notifs)

        called = 0
        Tootsee::Listener.new(stream).listen do |mention|
          called += 1
        end
        called.should eq 3
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
