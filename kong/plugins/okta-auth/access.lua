local _M = {}

local function extract_token(request)
  local authorization = request.get_headers()["authorization"]
  if not authorization then return nil end

  return string.match(authorization, '[Bb]earer (%w+)')
end

function _M.execute(request, conf)
  return extract_token(request)
end

return _M
