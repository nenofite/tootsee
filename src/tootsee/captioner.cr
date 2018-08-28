module Tootsee
  # Use Microsoft Azure to get a description of an image. Takes the image URL
  # and returns a string description.
  class Captioner
    def initialize(@http_client : Ports::HTTPClientPort, @config : Config); end

    # Ask Microsoft Azure to generate a description of the image at the given
    # URL.
    def caption(image_url : String) : String
      "todo :/" # TODO
    end
  end
end
