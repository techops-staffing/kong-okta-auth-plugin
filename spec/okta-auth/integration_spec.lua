local helpers = require "spec.helpers"
local cjson = require "cjson"

describe("Okta Auth", function()
  local client
  local admin_client
  local plugin
  local api

  setup(function()
    helpers.run_migrations()

    api = assert(helpers.dao.apis:insert {
        name = "api",
        uris = { "/api" },
        upstream_url = helpers.mock_upstream_url,
    })

    plugin = assert(helpers.dao.plugins:insert {
      api_id = api.id,
      name = "okta-auth",
      config = {
        client_id = "test_client_id",
        client_secret = "test_client_secret",
        authorization_server = "test_auth_server",
      }
    })

    assert(helpers.start_kong {
      custom_plugins = "okta-auth",
      nginx_conf = "spec/fixtures/custom_nginx.template",
    })

    client = helpers.proxy_client()
    admin_client = helpers.admin_client()
  end)

  teardown(function()
    if client then client:close() end
    if admin_client then admin_client:close() end
    helpers.stop_kong()
  end)

  describe("request", function()
    it("registered the plugin for the api", function()
      local response = assert(admin_client:send {
        method = "GET",
        path = "/plugins/" ..plugin.id,
      })
      local body = assert.res_status(200, response)
      local json = cjson.decode(body)
      assert.is_equal(api.id, json.api_id)
    end)

    it("returns Unauthorized if there is no authorization header", function ()
      local response = assert(client:send {
        method = "GET",
        path = "/api",
        headers = { }
      })
      assert.res_status(401, response)
    end)

    it("returns Unauthorized if token format is invalid", function ()
      local response = assert(client:send {
        method = "GET",
        path = "/api",
        headers = {
          authorization = 'invalid'
        }
      })
      assert.res_status(401, response)
    end)
  end)
end)
