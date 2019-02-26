local okta_api = require "kong.plugins.okta-auth.okta_api"
local json = require "cjson"
local jwt = require "kong.plugins.okta-auth.jwt"

local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  local token = string.match(authorization,
    '^[Bb]earer ([A-Za-z0-9-_]+%.[A-Za-z0-9-_]+%.[A-Za-z0-9-_]+)$'
  )

  if not token then return nil end

  return token:gsub("Bearer ",  "")
end

local function extract_data(token_data)
  local extracted_data = {}
  local required_data = {"cid", "sub", "scp", "groups"}

  for _, field in pairs(required_data) do
    if token_data[field] then extracted_data[field] = token_data[field] end
  end

  return extracted_data
end

local function make_oidc(token_data)
  ngx.log(ngx.INFO, "Make Oidc")

  local oidc = extract_data(token_data)
  local oidc_label = okta_api.get_oidc_label(oidc["cid"])

  if oidc_label then
    ngx.log(ngx.DEBUG, " Get Oidc label Success. oidc_label: ", oidc_label)
  else
    ngx.log(ngx.ERR, " Get Oidc label failed.")
    oidc_label = ''
  end

  oidc["Lab"] = oidc_label
  return oidc
end

function _M.execute(request, conf)
  local token = extract_token(request)
  if not token then return nil end

  jwks_url = conf.authorization_server .. "/" .. conf.api_version .. "/keys"
  token_data, err = jwt.validate_with_jwks(token, jwks_url)

  if err ~= nil then
    return nil
  end

  return true, make_oidc(token_data)
end

return _M
