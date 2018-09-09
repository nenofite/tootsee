module Tootsee
  # Use Microsoft Azure to get a description of an image. Takes the image URL
  # and returns a string description.
  class Captioner
    def initialize(@http_client : Ports::HTTPClientPort, @config : Config); end

    # Ask Microsoft Azure to generate a description of the image at the given
    # URL.
    def caption(image_url : String) : String
      json_body = {url: image_url}.to_json
      request_url = "#{@config[:azure_url]}?visualFeatures=Description&language=en"
      headers = HTTP::Headers{
        "Ocp-Apim-Subscription-Key" => @config[:azure_key],
        "Content-Type" => "application/json",
      }
      result = @http_client.exec("POST", request_url, headers, json_body)
      raise TootseeException.new(result.to_s) if result.status_code != 200
      json_result = JSON.parse(result.body)
      captions = json_result["description"]["captions"].as_a
      raise TootseeException.new("No caption available") if captions.empty?
      captions[0]["text"].as_s
    end
  end
end
