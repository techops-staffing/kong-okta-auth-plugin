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

  it("return true and introspect response if token it is valid", function()
    request = {
      get_headers = function(param) return { ["authorization"] = "Bearer token" } end
    }

    introspect_response = {
      [1] = '{ "active": true, "scope": "read write", "username": "user" }'
    }

    stub(okta_api, "introspect").returns(200, introspect_response)

    valid, token_data = access.execute(request, {})

    assert.is_true(valid)
    assert.are.equal(introspect_response, token_data)

    okta_api.introspect:revert()
  end)
end)
