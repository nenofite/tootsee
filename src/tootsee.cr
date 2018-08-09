require "mastodon"
require "http/server"

require "./tootsee/*"

# TODO: Write documentation for `Tootsee`
module Tootsee
  class Main
    @masto_url: String = ENV["MASTO_URL"]
    @access_token: String = ENV["ACCESS_TOKEN"]
    @port: Int32 = ENV["PORT"].to_i

    @client = Mastodon::REST::Client.new(url: @masto_url, access_token: @access_token)

    def send_toot
      puts "Sending toot..."
      result = @client.create_status("test toot!", visibility: "private")
      puts result
    end

    def serve
      server = HTTP::Server.new do |context|
        case context.request.path
        when "/push", "/push/"
          result = send_toot
          context.response.content_type = "text/plain"
          context.response.print(result.to_s)
        else
          context.response.respond_with_error("Nothing here", 404)
        end
      end

      puts "Listening on #{@port}"
      server.listen @port
    end
  end
end

Tootsee::Main.new.serve
