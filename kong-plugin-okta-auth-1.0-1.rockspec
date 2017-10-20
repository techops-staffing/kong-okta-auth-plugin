package = "kong-plugin-okta-auth"

version = "1.0-1"

source = {
  url = "git://github.com/techops-staffing/kong-okta-auth-plugin",
}

description = {
  summary = "Kong Plugin to validate OAuth 2.0 access tokens against an OKTA Authorization Server",
}

dependencies = {
}

local pluginName = "okta-auth"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".okta_api"] = "kong/plugins/"..pluginName.."/okta_api.lua",
  }
}
