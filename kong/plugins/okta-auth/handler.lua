local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.okta-auth.access"
local responses = require "kong.tools.responses"
local request = ngx.req

local function add_okta_headers(token_data)
  for key, value in pairs(token_data) do
    request.set_header("OKTA-"..key, value)
  end
end

local function string_starts(string, start)
  return string.sub(string, 1, string.len(start)) == start
end

local function strip_okta_headers()
  headers = request.get_headers()
  for key, value in pairs(headers) do
    if string_starts(key, "OKTA-") then
      request.set_header(key, nil)
    end
  end
end

local OktaAuth = BasePlugin:extend()
OktaAuth.PRIORITY = 1000

function OktaAuth:new()
  OktaAuth.super.new(self, "okta-auth")
end

function OktaAuth:access(conf)
  OktaAuth.super.access(self)

  authorized, token_data = access.execute(request, conf)
  if not authorized then return responses.send_HTTP_UNAUTHORIZED() end

  strip_okta_headers()
  request.set_header("Authorization", nil)
  add_okta_headers(token_data)
end

return OktaAuth
