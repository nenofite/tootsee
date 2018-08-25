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

      it "strips HTML from the mention" do
        notifs = [FakeEntities.fake_mention]
        notifs[0].status.not_nil!.content.should eq "<p>Hello world.</p>"
        stream = MockMastodonStream.new(notifs)

        Tootsee::Listener.new(stream).listen do |mention|
          mention[:text].should eq "Hello world."
        end
      end
    end

    describe "#strip_html" do
      it "strips HTML tags from the string" do
        str = "<many><!-- types --> of<br /> tags </many>."
        Tootsee::Listener.strip_html(str).should eq " of tags ."
      end
    end
  end
end
