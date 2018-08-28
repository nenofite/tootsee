require "spec"
require "../src/tootsee"
require "./fake_entities"
require "./mock_ports"

# A Config with all empty strings.
def empty_config : Tootsee::Config
  {
    masto_url: "",
    access_token: "",
    port: 0,
    azure_url: "",
    azure_key: "",
  }
end
