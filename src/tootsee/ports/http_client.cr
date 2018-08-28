module Tootsee
  module Ports
    # A port for making HTTP client requests.
    abstract class HTTPClientPort
      abstract def exec(
        method : String,
        url : String | URI,
        headers : HTTP::Headers? = nil,
        body : BodyType = nil,
        tls = nil,
      ) : HTTP::Client::Response
    end

    # Actual implementation of the HTTP client. In tests, use
    # `MockHTTPClientPort` instead.
    class HTTPClientPortI < HTTPClientPort
      # TODO
    end
  end
end
