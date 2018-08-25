require "../../spec_helper"

module Tootsee
  describe Replier do
    describe "#toot" do
      it "sends toots" do
        client = MockMastodonClient.new
        replier = Replier.new(client)
        mention1 = {
          text: "say hi",
          id: "123",
          spoiler_text: "",
          visibility: "public",
        }
        mention2 = {
          text: "say bye",
          id: "456",
          spoiler_text: "byeee",
          visibility: "direct",
        }

        replier.reply("Hello world", mention1)
        replier.reply("Goodbye", mention2)
        client.toots.should eq [
          {
            text: "Hello world",
            in_reply_to_id: "123",
            spoiler_text: "",
            visibility: "public",
          },
          {
            text: "Goodbye",
            in_reply_to_id: "456",
            spoiler_text: "byeee",
            visibility: "direct",
          },
        ]
      end
    end
  end
end
