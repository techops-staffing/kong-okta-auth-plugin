local https = require "ssl.https"
local ltn12 = require "ltn12"
local mime = require "mime"
--local constant = require "kong.plugins.okta-auth.constant"
local singletons = require "kong.singletons"

local _M = {}

local function format_headers(client_id, client_secret, content_length)
  return {
    ["Content-Type"] = "application/x-www-form-urlencoded",
    ["Content-Length"] = content_length,
    ["Authorization"] = "Basic "..mime.b64(client_id..":"..client_secret)
  }
end

local function send_request(url, method, headers, body)
  local response_body = {}
  local response, status_code, response_headers, status = https.request {
      url = url,
      method = method,
      headers = headers,
      source = ltn12.source.string(body),
      sink = ltn12.sink.table(response_body)
  }
  return status_code, response_body, response_headers
end

function _M.introspect(auth_server, api_version, client_id, client_secret, token)
  local url = auth_server.."/"..api_version.."/introspect"
  local body_params = "token="..token.."&token_type_hint=access_token"
  local headers = format_headers(client_id, client_secret, #body_params)

  local status_code, response_body, response_headers = send_request(
    url, "POST", headers, body_params
  )

  if status_code ~= 200 or not response_body then
    return nil
  end

  return response_body[1] or response_body
end

local function get_Oidc_headers()
    --local token = constant.getenv("OKTA_TOKEN")
    local token = "00mDOufhvNR7EOpKGt5S2IL_MvaldmMA9CYEf0fx2z"
    return {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Authorization"] = "SSWS " .. token
    }
end

local function fetch_objc_label(oidc_id)
    ngx.log(ngx.INFO, "fetch_objc_label :oidc id ", oidc_id)

    --local base_url = constant.getenv("OKTA_BASE_URL")
    local base_url = "https://dev-395756.oktapreview.com"
    ngx.log(ngx.DEBUG, "Get Env of base url ", base_url)

    local url = base_url .. '/api/v1/apps/' .. oidc_id
    local headers = get_Oidc_headers()
    local pok, status, response_body, response_headers = pcall(send_request,
            url, "GET", headers, body_params
    )

    if not pok or status ~= 200 or not response_body then
        ngx.log(ngx.ERR, "Assemble OIDC Label failed, because ", status)
        return nil
    end

    ngx.log(ngx.DEBUG, "Get Response Success response_body: ", response_body)
    if type(response_body) == "table" then
        for key, value in pairs(response_body) do
            printf(key, value)
        end
    end

    local oidc = response_body[1] or response_body
    return oidc.label
end

function _M.get_oidc_label(oidc_id)
    ngx.log(ngx.INFO, "Get OIDC label by oidc id: ", oidc_id)

    local cache = singletons.cache
    local oidc_label

    if cache ~= nil then
        local ttl, err, value = cache:probe(oidc_id)
        if ttl then
            oidc_label = value
        else
            oidc_label, err = cache:get(oidc_id, nil, fetch_objc_label, oidc_id)
        end

        if err then
            ngx.log(ngx.ERR, "Cache OIDC label by it's id failed: ", err)
            oidc_label = nil
        end
    end

    if not oidc_label then
        oidc_label = fetch_objc_label(oidc_id)
    end

    return oidc_label
end

return _M
