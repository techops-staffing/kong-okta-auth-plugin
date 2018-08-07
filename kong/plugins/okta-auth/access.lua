local okta_api = require "kong.plugins.okta-auth.okta_api"
local json = require "cjson"
local jwt = require "kong.plugins.okta-auth.jwt"

local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization,
    '^[Bb]earer ([A-Za-z0-9-_]+%.[A-Za-z0-9-_]+%.[A-Za-z0-9-_]+)$'
  )
end

local function is_token_valid(token_data)
  return token_data['active']
end

local function extract_data(token_data)
  local extracted_data = {}
  local required_data = {"username", "group", "scope"}

  for _, field in pairs(required_data) do
    if token_data[field] then extracted_data[field] = token_data[field] end
  end

  return extracted_data
end

function _M.execute(request, conf)
  local token = extract_token(request)
  if not token then return nil end

  jwks_url = "https://" .. conf.authorization_server .. ".oktapreview.com/oauth2/" .. conf.client_id .. "/" .. conf.api_version .. "/keys"
  token_data, err = jwt.validate_with_jwks(token, jwks_url)

  if err then return nil end

  return is_token_valid(token_data), extract_data(token_data)
end

return _M
