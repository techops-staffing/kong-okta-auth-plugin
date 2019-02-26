local okta_api = require "kong.plugins.okta-auth.okta_api"
local https = require "ssl.https"
local singletons = require "kong.singletons"

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

  it("returns oidc_label if get_oidc_label by cache:probe success", function()
    stub(singletons, "cache").returns("cache")
    stub(singletons.cache, "probe").returns("ttl", nil, "value")

    local oidc_label = okta_api.get_oidc_label("oidc_id")

    assert.is_not_nil(oidc_label)

  end)

  it("returns oidc_label if get_oidc_label by cache:get success", function()
    stub(singletons, "cache").returns("cache")
    stub(singletons.cache, "probe").returns(nil, nil, nil)
    stub(singletons.cache, "get").returns("oidc_label", nil)

    local oidc_label = okta_api.get_oidc_label("oidc_id")

    assert.is_not_nil(oidc_label)

    https.request:revert()
  end)

  it("returns oidc_label if get_oidc_label by get_oidc_label send request", function()
    stub(singletons, "cache").returns(nil)
    stub(https, "request").returns("oidc_label", 200, "headers", "200 ")

    local oidc_label = okta_api.get_oidc_label("oidc_id")

    assert.is_not_nil(oidc_label)

    https.request:revert()
  end)
end)
