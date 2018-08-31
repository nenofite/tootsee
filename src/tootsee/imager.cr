require "uri"
require "myhtml"

module Tootsee
  # The imager retrieves image URLs from DuckDuckGo image search.
  class Imager
    def initialize(@http_client : Ports::HTTPClientPort); end

    # Get an image URL matching the given phrase
    def image(phrase : String) : String
      # URL encode the phrase
      phrase_esc = URI.escape(phrase, space_to_plus: true)

      # Get the image search from DuckDuckGo
      url = "https://duckduckgo.com/?q=#{phrase_esc}&t=hj&iar=images&iax=images&ia=images"
      response = @http_client.exec(
        "GET",
        url,
        HTTP::Headers{"Accept" => "text/html"},
      )
      raise TootseeException.new(response.to_s) if response.status_code != 200

      # Parse the HTML
      page = Myhtml::Parser.new(response.body)

      # Extract images and get their src
      img_srcs = page
        .nodes(:img)
        .compact_map(&.attribute_by("src"))
        .reject(&.empty?)
        .to_a

      # Pick a random one
      img_srcs.sample(1).first
    end
  end
end
