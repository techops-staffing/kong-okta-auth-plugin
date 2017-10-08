local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.okta-auth.access"
local responses = require "kong.tools.responses"

local OktaAuth = BasePlugin:extend()

OktaAuth.PRIORITY = 1000

function OktaAuth:new()
  OktaAuth.super.new(self, "okta-auth")
end

function OktaAuth:access(conf)
  OktaAuth.super.access(self)

  authorized, token_data = access.execute(ngx.req, conf)
  if not authorized then return responses.send_HTTP_UNAUTHORIZED() end
end

return OktaAuth
