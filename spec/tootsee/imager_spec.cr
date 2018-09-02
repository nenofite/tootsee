require "../../spec_helper"

module Tootsee
  describe Imager do
    describe "#image" do
      it "retrieves pages from DuckDuckGo" do
        http_client = MockPorts::MockHTTPClientPort.new do
          HTTP::Client::Response.new(200, <<-HTML, HTTP::Headers{"Content-Type" => "text/html"})
            <!DOCTYPE html>
            <html>
              <body>
                <div />
                <div>
                  <img src="corgi">
                  <img src="corgi">
                </div>
              </body>
            </html>
          HTML
        end

        imager = Imager.new(http_client)
        result = imager.image("i like bird 🐦")

        http_client.calls.should eq [
          {
            method: "GET",
            url: "https://www.google.com/search?q=i+like+bird+%F0%9F%90%A6&tbm=isch",
            headers: HTTP::Headers{
              "Accept" => "text/html",
            },
            body: nil,
          }
        ]

        # Not sure how to test the random part without mocking/spying on `Random`
        result.should eq "corgi"
      end

      it "raises an error on a non-200" do
        http_client = MockPorts::MockHTTPClientPort.new do
          HTTP::Client::Response.new(400)
        end

        imager = Imager.new(http_client)

        begin
          imager.image("i like bird 🐦")
          false.should eq true
        rescue TootseeException
        end
      end
    end
  end
end
