local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization, '[Bb]earer (%w+)')
end

function _M.execute(request, conf)
  token = extract_token(request)
  if not token then return nil end

  return true
  --TODO: validate token
  --TODO: extract token data
  --TODO: return valid, token_data
end

return _M
