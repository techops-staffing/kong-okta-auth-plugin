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

    it("return false if token type is not bearer or Bearer", function()
      request = {
        get_headers = function(param)
          return { ["authorization"] = "token" }
        end
      }
      valid, token_data = access.execute(request, {})
      assert.is.not_true(valid)
    end)

    it("return false if token has not tree parts separated by period", function()
      request = {
        get_headers = function(param)
          return { ["authorization"] = "Bearer part1.part2" }
        end
      }
      valid, token_data = access.execute(request, {})
      assert.is.not_true(valid)
    end)

    it("return false if token has invalid characters", function()
      request = {
        get_headers = function(param)
          return { ["authorization"] = "Bearer pa*rt1.part2.part3" }
        end
      }
      valid, token_data = access.execute(request, {})
      assert.is.not_true(valid)
    end)
  end)

  describe("Introspection of a valid token", function()
    before_each(function()
      request = {
        get_headers = function(param)
          return { ["authorization"] = "Bearer header.body.signature" }
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
