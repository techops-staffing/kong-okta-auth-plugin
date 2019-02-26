-- Constant For Env

local _M = {}

function _M.get_env_when_nginx_worker_init()
    ngx.log(ngx.INFO, "get_env_when_nginx_worker_init ")

    _M["OKTA_BASE_URL"] = os.getenv('OKTA_BASE_URL')
    _M["OKTA_TOKEN"] = os.getenv('OKTA_TOKEN')
end

function _M.getenv(key)
    ngx.log(ngx.INFO, "getenv with key: ", key)

    if _M and table.getn(_M) ~= 0 then
        return _M[key]
    else
        ngx.log(ngx.ERR, "getenv Failed with key: ", key)
        return nil
    end
end

return _M