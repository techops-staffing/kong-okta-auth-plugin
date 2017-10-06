local okta_api = require "kong.plugins.okta-auth.okta_api"

local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization, '[Bb]earer ([^\n]+)')
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

  return true, response
  --TODO: extract token data
  --TODO: return valid, token_data
end

return _M
