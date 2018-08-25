require "../../spec_helper"

module Tootsee
  describe Replier do
    describe "#toot" do
      it "sends toots" do
        client = MockMastodonClient.new
        replier = Replier.new(client)
        mention1 = {
          text: "say hi",
          id: 123,
        }
        mention2 = {
          text: "say bye",
          id: 456,
        }

        replier.reply("Hello world", mention1)
        replier.reply("Goodbye", mention2)
        client.toots.should eq [{"Hello world", 123}, {"Goodbye", 456}]
      end
    end
  end
end
