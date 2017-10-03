local plugin = require("kong.plugins.base_plugin"):extend()
local access = require "kong.plugins.okta-auth.access"
local responses = require "kong.tools.responses"

function plugin:new()
  plugin.super.new(self, "okta-auth")
end

function plugin:access(plugin_conf)
  plugin.super.access(self)
  authorization = access.execute(ngx.req, conf)
  if not authorization then
    return responses.send_HTTP_UNAUTHORIZED()
  end
end

plugin.PRIORITY = 1000
return plugin
