local helpers = require "spec.helpers"
local access = require "kong.plugins.okta-auth.access"
local okta_api = require "kong.plugins.okta-auth.okta_api"

describe("Access", function()
  it("return null if token is missing", function()
    request = {
      get_headers = function(param) return {} end
    }
    valid, token_data = access.execute(request, {})
    assert.is.not_true(valid)
  end)

  it("return null if token in a wrong format", function()
    request = {
      get_headers = function(param) return { ["authorization"] = "token" } end
    }
    valid, token_data = access.execute(request, {})
    assert.is.not_true(valid)
  end)

  --FIXME
  it("return true if token is in a correct format", function()
    request = {
      get_headers = function(param) return { ["authorization"] = "Bearer token" } end
    }
    valid, token_data = access.execute(request, {})
    assert.is_true(valid)
  end)

  --[[it("return token data if it is valid", function()
    introspect_response = {
      active = true,
      scope = "read write",
      username = "user"
    }
    request = {
      get_headers = function(param) return { ["Authorization"] = "Bearer token" } end
    }
    access.execute(request, {})

    access.execute()
    local status, response = okta_api.introspect(
      "server", "api_version", "client_id", "client_secret", "token"
    )

    assert.are.equal(status, 200)

    okta_api.request:revert()
  end)--]]
end)
