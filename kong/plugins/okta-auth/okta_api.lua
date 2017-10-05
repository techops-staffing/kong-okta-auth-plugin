local https = require "ssl.https"
local ltn12 = require "ltn12"
local mime = require "mime"

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

  return status_code, response_body
end

return _M
