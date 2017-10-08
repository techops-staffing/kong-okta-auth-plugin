local okta_api = require "kong.plugins.okta-auth.okta_api"
local json = require "cjson"

local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization, '[Bb]earer ([^\n]+)')
end

local function extract_data(response)
  --TODO: extract just relevant data
  return json.decode(response[1])
end

function _M.execute(request, conf)
  token = extract_token(request)
  if not token then return nil end

  status_code, response = okta_api.introspect(
    conf.authorization_server,
    conf.api_version,
    conf.client_id,
    conf.client_secret,
    token
  )

  if status_code ~= 200 then return false end

  response_data = extract_data(response)
  return true, response_data
end

return _M
