local _M = {}

function _M.execute(request, conf)
  return request.get_headers()["authorization"]
end

return _M
