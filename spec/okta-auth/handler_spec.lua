_G.ngx = require "spec.okta-auth.ngx"

local access = require "kong.plugins.okta-auth.access"
local handler = require "kong.plugins.okta-auth.handler"
local responses = require "kong.tools.responses"
local request = ngx.req

describe("Handler", function()
  it("Check if all OKTA-* headers from original request were striped", function()
    stub(access, "execute").returns(true, {})
    stub(request, "set_header")

    handler.access({})

    assert.stub(request.set_header).was_called_with("OKTA-group", nil)
    assert.stub(request.set_header).was_called_with("OKTA-test", nil)
    assert.stub(request.set_header).was_not_called_with("test", nil)

    access.execute:revert()
    request.set_header:revert()
  end)

  it("Check if token header was deleted before redirecting to API", function()
    stub(access, "execute").returns(true, {})
    stub(request, "set_header")

    handler.access({})

    assert.stub(request.set_header).was_called_with("authorization", nil)

    access.execute:revert()
    request.set_header:revert()
  end)

  it("Check if headers were included if token is valid", function()
    token_data = {
      ["scope"] = "read write",
      ["username"] = "user",
      ["group"] = {"Everyone"}
    }

    stub(access, "execute").returns(true, token_data)
    stub(request, "set_header")

    handler.access({})

    for key, value in pairs(token_data) do
      assert.stub(request.set_header).was_called_with("OKTA-"..key, value)
    end

    access.execute:revert()
    request.set_header:revert()
  end)

  it("Check if response is unauthorized if token is invalid", function()
    stub(access, "execute").returns(false)
    stub(responses, "send_HTTP_UNAUTHORIZED")

    handler.access({})

    assert.stub(responses.send_HTTP_UNAUTHORIZED).was_called()

    access.execute:revert()
    responses.send_HTTP_UNAUTHORIZED:revert()
  end)
end)
