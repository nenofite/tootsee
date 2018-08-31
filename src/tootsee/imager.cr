module Tootsee
  # The imager retrieves image URLs from DuckDuckGo image search.
  class Imager
    def initialize(@http_client : Ports::HTTPClientPort); end

    # Get an image URL matching the given phrase
    def image(phrase : String) : String
      "TODO"
    end
  end
end
