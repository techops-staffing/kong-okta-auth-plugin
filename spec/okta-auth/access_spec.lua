local helpers = require "kong.spec.helpers"
local access = require "kong.plugins.okta-auth.access"
local okta_api = require "kong.plugins.okta-auth.okta_api"

describe("Access", function()
  describe("Token format validation", function()
    it("return false if token is missing", function()
      request = {
        get_headers = function(param) return {} end
      }
      valid, token_data = access.execute(request, {})
      assert.is.not_true(valid)
    end)

    it("return false if token in a wrong format", function()
      request = {
        get_headers = function(param) return { ["authorization"] = "token" } end
      }
      valid, token_data = access.execute(request, {})
      assert.is.not_true(valid)
    end)
  end)

  describe("Token introspection", function()
    before_each(function()
      request = {
        get_headers = function(param)
          return { ["authorization"] = "Bearer token" }
        end
      }
    end)

    it("return false if introspection fails", function()
      introspect_response = nil
      stub(okta_api, "introspect").returns(introspect_response)

      valid = access.execute(request, {})

      assert.is_not_true(valid)

      okta_api.introspect:revert()
    end)

    it("return false if token is not valid by introspection", function()
      introspect_response = '{ "active": false }'
      stub(okta_api, "introspect").returns(introspect_response)

      valid = access.execute(request, {})

      assert.is_not_true(valid)

      okta_api.introspect:revert()
    end)

    it("return true and introspect response if token is valid", function()
      introspect_response = [[{
        "active": true,
        "scope": "read write",
        "username": "user",
        "group": ["Everyone"],
        "exp": 1507397726
      }]]

      expected_token_data = {
        ["scope"] = "read write",
        ["username"] = "user",
        ["group"] = {"Everyone"}
      }

      stub(okta_api, "introspect").returns(introspect_response)

      valid, token_data = access.execute(request, {})

      assert.is_true(valid)
      assert.are.same(expected_token_data, token_data)

      okta_api.introspect:revert()
    end)
  end)
end)
