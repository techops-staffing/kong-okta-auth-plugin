package = "kong-plugin-okta-auth"

version = "1.0-1"

source = {
  url = "git://github.com/techops-staffing/kong-okta-auth-plugin",
}

description = {
  summary = "Kong Plugin to validate OAuth 2.0 access tokens against an OKTA Authorization Server",
}

dependencies = {
  "lua ~> 5.1",
  "lbase64",
  "lua-cjson"
}

local pluginName = "okta-auth"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".okta_api"] = "kong/plugins/"..pluginName.."/okta_api.lua",
    ["kong.plugins."..pluginName..".jwt"] = "kong/plugins/"..pluginName.."/jwt.lua",
    ["kong.plugins."..pluginName..".jwks"] = "kong/plugins/"..pluginName.."/jwks.lua"
  }
}
