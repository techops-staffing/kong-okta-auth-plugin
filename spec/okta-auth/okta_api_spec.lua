local helpers = require "spec.helpers"
local okta_api = require "kong.plugins.okta-auth.okta_api"
local https = require "ssl.https"

describe("Okta API", function()
  it("returns http request result", function()
    stub(https, "request").returns("response", 200, "headers", "200 OK")

    local status, response = okta_api.introspect(
      "server", "api_version", "client_id", "client_secret", "token"
    )

    assert.are.equal(status, 200)

    https.request:revert()
  end)
end)
