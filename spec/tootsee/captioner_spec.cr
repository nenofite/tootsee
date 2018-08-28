require "../../spec_helper"

module Tootsee
  describe Captioner do
    describe "#caption" do
      it "calls the Azure API" do
        http_client = MockPorts::MockHTTPClientPort.new do |params|
          HTTP::Client::Response.new(200, <<-JSON, HTTP::Headers{"Content-Type" => "application/json"})
            {
              "description": {
                "captions": [
                  {
                    "text": "Test description",
                    "confidence": 0.91
                  },
                  {
                    "text": "Another description",
                    "confidence": 0.43
                  }
                ]
              }
            }
          JSON
        end
        config = empty_config.merge({
          azure_url: "https://test_url.foo",
          azure_key: "test-azu-key",
        })
        captioner = Captioner.new(http_client, config)
        result = captioner.caption("http://testimage.com/foo_bar?32")

        http_client.calls.should eq [
          {
            method: "POST",
            url: "https://test_url.foo?visualFeatures=Description&language=en",
            headers: HTTP::Headers{
              "Ocp-Apim-Subscription-Key" => "test-azu-key",
              "Content-Type" => "application/json",
            },
            body: "{\"url\":\"http://testimage.com/foo_bar?32\"}",
          }
        ]
        result.should eq "Test description"
      end
    end
  end
end
