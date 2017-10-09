local okta_api = require "kong.plugins.okta-auth.okta_api"
local json = require "cjson"

local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization, '[Bb]earer ([^\n]+)')
end

local function is_token_valid(token_data)
  return token_data['active']
end

local function extract_data(token_data)
  --TODO: extract just relevant data
  return token_data
end

function _M.execute(request, conf)
  token = extract_token(request)
  if not token then return nil end

  response = okta_api.introspect(
    conf.authorization_server,
    conf.api_version,
    conf.client_id,
    conf.client_secret,
    token
  )

  if not response then return false end

  token_data = json.decode(response)
  if is_token_valid(token_data) then
    response_data = extract_data(token_data)
    return true, response_data
  end

  return false -- token invalid
end

return _M
