package = "kong-plugin-okta-auth"

version = "0.1.0-1"

supported_platforms = {"linux", "macosx"}

source = {
  url = "git://github.com/techops-staffing/kong-okta-auth-plugin",
}

description = {
  summary = "Kong plugin to handle Okta generated token introspection",
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
  }
}
