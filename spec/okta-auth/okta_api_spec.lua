local helpers = require "spec.helpers"
local okta_api = require "kong.plugins.okta-auth.okta_api"
local https = require "ssl.https"

describe("Okta API", function()
  it("returns response if introspect API request status code is 200", function()
    stub(https, "request").returns("response", 200, "headers", "200 OK")

    local response = okta_api.introspect(
      "server", "api_version", "client_id", "client_secret", "token"
    )

    assert.is_not_nil(response)

    https.request:revert()
  end)

  it("returns nil if introspect API request status code is not 200", function()
    stub(https, "request").returns("response", 404, "headers", "404 Not Found")

    local response = okta_api.introspect(
      "server", "api_version", "client_id", "client_secret", "token"
    )

    assert.is_nil(response)

    https.request:revert()
  end)
end)
