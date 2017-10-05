local helpers = require "spec.helpers"

describe("Okta Auth", function()
  local client

  setup(function()
    local api = assert(helpers.dao.apis:insert {
        name = "api",
        uris = { "/api" },
        upstream_url = helpers.mock_upstream_url,
    })

    assert(helpers.dao.plugins:insert {
      api_id = api.id,
      name = "okta-auth",
    })

    assert(helpers.start_kong {
      custom_plugins = "okta-auth",
      nginx_conf = "spec/fixtures/custom_nginx.template"
    })
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function()
    if client then client:close() end
  end)

  describe("request", function()
    it("returns Unauthorized if there is no authorization header", function ()
      local response = assert(client:send {
        method = "GET",
        path = "/api",
        headers = {
        }
      })

      assert.response(response).has.status(401)
    end)

    it("returns Unauthorized if token format is invalid", function ()
      local response = assert(client:send {
        method = "GET",
        path = "/api",
        headers = {
          authorization = 'invalid'
        }
      })

      assert.response(response).has.status(401)
    end)

    it("returns OK if token format is valid", function ()
      local response = assert(client:send {
        method = "GET",
        path = "/api",
        headers = {
          authorization = "Bearer token"
        }
      })

      assert.response(response).has.status(200)
    end)
  end)
end)
