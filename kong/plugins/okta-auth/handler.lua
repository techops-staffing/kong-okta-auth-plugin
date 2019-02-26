local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.okta-auth.access"
local responses = require "kong.tools.responses"
local constant = require "kong.plugins.okta-auth.constant"
local request = ngx.req

local function add_okta_headers(token_data)
  for key, val in pairs(token_data) do
    if type(val) == 'table' then
      result = {}
      for i, v in pairs(val) do
        table.insert(result, v)
        if i ~= table.getn(val) then
          table.insert(result, ',')
        end
      end
      val = table.concat(result)
    end
    request.set_header("OKTA-" .. key, val)
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

function OktaAuth:init_worker()
  OktaAuth.super.new(self, "okta-auth")
  constant.get_env_when_nginx_worker_init()
end

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
