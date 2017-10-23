-- test fixtures
return {
  encode_base64 = function(str) end,
  req = {
    set_header = function() end,
    get_headers = function()
        return {
          ["OKTA-group"] = "groups",
          ["OKTA-test"] = "test",
          ["test"] = "test",
        }
      end,
  },
  resp = {},
  now = function() end,
  log = function(...) end,
  sleep = function(t) end,
  timer = {},
  socket = {},
  re = {},
  config = {
    ngx_lua_version = ""
  }
}
