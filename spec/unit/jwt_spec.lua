local jwt = require "kong.plugins.okta-auth.jwt"
local jwks = require "kong.plugins.okta-auth.jwks"
local inspect = require "inspect"

local jwks_keys = [[
{"keys":[{"alg":"RS256","e":"AQAB","n":"n5eMflAv9u5Lguj8FHPSlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk_optA8CgH5s7gmABfHATJKCJA6gA6Zv_ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df-cr84-6HFOyQa_TTybqGv1sGq-kdk-pewISDfKS5k-ehGGok-3FKwKW0FLX8BZK6Edp95R7KXeH-WOIO1uXZTgnLVoaR34S9p0gqYQ-wEy3_PjK3dv09D2BgGlxl5NM5lcZaWn4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv-_EWEiU6FskrmTMhOH0JQ","kid":"Twfk2D3tYY-xo61vDoRnHdcnERqdQz-xR2zRHHja3Hk","kty":"RSA","use":"sig"},{"alg":"RS256","e":"AQAB","n":"zTsIHUnehKVJjFPu4c8hoLsy-PwANzGDeDPJN6W5wHwjUz_4yGz7_THbCOD5v2hKWYh02qWTqfCmvFaKykjif-6Ofsl1VCLR52pN2o53Sdhr0GFBTU1pWrxh7LyAH3hIqMmv2gWW_dwoF8s-LM3Mwz0bQJ_U3rzR0ToN6aTvbNogwS4cV1hlDMCMYaHXe7XFF9X-TY6Rk1BsJvg0wYtKEopCQIPVGlU8-4GjQHZdEhyGJacAx0WxwYnbIsRsyVgY_FNa91zeX7Ck3F2vB556dMLVpBN8pvi4ADWloDBDVJpYg39SH_roT1hbXDc3i_eBrC50deb0nttlqZWIlbTSeQ","kid":"DhQQVMtmiH9S-68kW0PLMpEJFXgj-zxXfPcRH622Xeg","kty":"RSA","use":"sig"}]}
]]

describe("main", function()
  describe("when token is not A JWT", function()
    it("returns invalid json error", function()
      local invalid_token = [[
eyJraWQiOiJUd2ZrMkQzdFlZLXhvNjF2RG9SbkhkYoteFIyelJISGphM0hrIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULkhZbVZPSkFNbVBFRXFUakpGYVhhMEZrek8xOEN4ejJaekV5aVRKOWZpLUEiLCJpc3MiOiJodHRwczovL2Rldi0zOTU3NTYub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNmYWZsbmVkaFNUU3A5WjBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTM0MTg1OTI4LCJleHAiOjE1MzQxODk1MjgsImNpZCI6IjBvYWV5a2V6dGNJQlJvbEhzMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2FleWtlenRjSUJSb2xIczBoNyJ9.TqzS5XwTfscPQMxNCGkpwXHHPngQDImzZHIHQPvwftvs2dvXVcALcOJZHk26I8E9bblZxsda5McyXAj9f9_1VrxSl3KBbozkGV-3cTY__Db6QD3HofUMy4z-Y5wmkOLnmQtlOQ2__OjBFtBahtI2Mk0dfJTK2Fd5PvR1uXWYga7l6dEXJXGmfAreAst7phtAa9U8s4lWAhSsq7M5DgnxGEwsZTvEYrU60oGBbuQsk-U7gkizW8EFEfiK-FrWGSLgMqlrQMEHo0QiYlwiPh-kQCHBC8ZEruU5TVeTbbSe4Ijz7nocjhCh31zTkD5ShnPcrbWhsm9jWcCuoc1rKAq5cg
      ]]
      jwks.to_pem = function()
        return "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5eMflAv9u5Lguj8FHPS\nlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk/optA8CgH5s7gm\nABfHATJKCJA6gA6Zv/ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df+cr84+\n6HFOyQa/TTybqGv1sGq+kdk+pewISDfKS5k+ehGGok+3FKwKW0FLX8BZK6Edp95R\n7KXeH+WOIO1uXZTgnLVoaR34S9p0gqYQ+wEy3/PjK3dv09D2BgGlxl5NM5lcZaWn\n4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv+/EWEiU6FskrmTMhOH0\nJQIDAQAB\n-----END PUBLIC KEY-----\n"
      end

      local decoded_token, error = jwt.validate_with_jwks(invalid_token, jwks_keys)

      assert.same(error, "Invalid json")
    end)
  end)

  describe("when token is from another auth server", function()
    it("returns invalid signature error", function()
      local token = [[
eyJraWQiOiJHM0ItSm56MmV2NVlmcS1pUVhCRlB2QzNYMkdnSC1LOEs2UXBxVHRubXo0IiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULjNEYkkyQklja2hKLUIzc2dBdjE2SncyMUxhZzlFVDVudm1aa0hZLVgyUFEiLCJpc3MiOiJodHRwczovL2Rldi00ODIyNjAub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNlczNycXV1bWRpcTJieTBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTM0NzkyOTc4LCJleHAiOjE1MzQ3OTY1NzgsImNpZCI6IjBvYWV3cWVhYWNDZHhBa3JrMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2Fld3FlYWFjQ2R4QWtyazBoNyJ9.Kgej2DFqLEnYAghfZZbySUDYhgQD8igz0e6VKGv-YjoFkEUaHmjULRGmc42Lcc7R1upj-30qpW7vn5J-cYuV6-FDqS6VYBCgT984Zs8JzD4xLM0GU2qKswGF_EqbHMvu61pRZ_dRu6V-BSDC0179aFQqYdkYbcc4gIPk8KXgJcdciqHclGR4Dfo8CCfqqV_R7Y-KOvE7th_1-08p6QhTTaWR3lain30-IOwmFLNHkJ26W-zVmo2-Zld4efjVW9LrPtczEiVGSK-YkTJRQDsRS0gme-WkURtkGGAl7Wfe2Uen6XqTBocpr7jEd4-ui1j6A8EN1zEi7aX-4p0_G9596A
      ]]
      jwks.to_pem = function()
        return "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5eMflAv9u5Lguj8FHPS\nlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk/optA8CgH5s7gm\nABfHATJKCJA6gA6Zv/ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df+cr84+\n6HFOyQa/TTybqGv1sGq+kdk+pewISDfKS5k+ehGGok+3FKwKW0FLX8BZK6Edp95R\n7KXeH+WOIO1uXZTgnLVoaR34S9p0gqYQ+wEy3/PjK3dv09D2BgGlxl5NM5lcZaWn\n4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv+/EWEiU6FskrmTMhOH0\nJQIDAQAB\n-----END PUBLIC KEY-----\n"
      end

      local decoded_token, error = jwt.validate_with_jwks(token, jwks_keys)

      assert.same(error, "Invalid signature")
    end)
  end)

  describe("when token is expired", function()
    it("returns expired token error", function()
      local token = [[
eyJraWQiOiJUd2ZrMkQzdFlZLXhvNjF2RG9SbkhkY25FUnFkUXoteFIyelJISGphM0hrIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULkhZbVZPSkFNbVBFRXFUakpGYVhhMEZrek8xOEN4ejJaekV5aVRKOWZpLUEiLCJpc3MiOiJodHRwczovL2Rldi0zOTU3NTYub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNmYWZsbmVkaFNUU3A5WjBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTM0MTg1OTI4LCJleHAiOjE1MzQxODk1MjgsImNpZCI6IjBvYWV5a2V6dGNJQlJvbEhzMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2FleWtlenRjSUJSb2xIczBoNyJ9.TqzS5XwTfscPQMxNCGkpwXHHPngQDImzZHIHQPvwftvs2dvXVcALcOJZHk26I8E9bblZxsda5McyXAj9f9_1VrxSl3KBbozkGV-3cTY__Db6QD3HofUMy4z-Y5wmkOLnmQtlOQ2__OjBFtBahtI2Mk0dfJTK2Fd5PvR1uXWYga7l6dEXJXGmfAreAst7phtAa9U8s4lWAhSsq7M5DgnxGEwsZTvEYrU60oGBbuQsk-U7gkizW8EFEfiK-FrWGSLgMqlrQMEHo0QiYlwiPh-kQCHBC8ZEruU5TVeTbbSe4Ijz7nocjhCh31zTkD5ShnPcrbWhsm9jWcCuoc1rKAq5cg
      ]]
      jwks.to_pem = function()
        return "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5eMflAv9u5Lguj8FHPS\nlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk/optA8CgH5s7gm\nABfHATJKCJA6gA6Zv/ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df+cr84+\n6HFOyQa/TTybqGv1sGq+kdk+pewISDfKS5k+ehGGok+3FKwKW0FLX8BZK6Edp95R\n7KXeH+WOIO1uXZTgnLVoaR34S9p0gqYQ+wEy3/PjK3dv09D2BgGlxl5NM5lcZaWn\n4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv+/EWEiU6FskrmTMhOH0\nJQIDAQAB\n-----END PUBLIC KEY-----\n"
      end

      local decoded_token, error = jwt.validate_with_jwks(token, jwks_keys)

      assert.same(error, "Not acceptable by exp")
    end)
  end)

  describe("when token is valid", function()
    it("returns decoded token", function()
      local token = [[
      eyJraWQiOiJUd2ZrMkQzdFlZLXhvNjF2RG9SbkhkY25FUnFkUXoteFIyelJISGphM0hrIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULlhtVmt0T0VJQndlUE9oMXNhSGVqNUhhT1l1LV9IN3RYMWpuVkFjTVBEeFEiLCJpc3MiOiJodHRwczovL2Rldi0zOTU3NTYub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNmYWZsbmVkaFNUU3A5WjBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTMyNDUyMDM4LCJleHAiOjE1MzI0NTU2MzgsImNpZCI6IjBvYWZmeHNjbm5sMHNmVXYzMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2FmZnhzY25ubDBzZlV2MzBoNyJ9.QdA9RHEVeg2vNbI3tD_N2TD-IyBRXxc-1j56Ksm1go5RZ2H8QnE39-lZMRDinPZNx6h_Xv213YMhu3QmCuPXWASbu6VWRkeXdKX1bgj3MS4kH0264jOZ5ScwlYB5-49AUx7qhg9ZRp83HIbM3wpSl8S_HoR2S1poCKZIBvFv9MZ2NLCtjRR95n2d7gGCRuGo05Xn22mzAXBqcAo_LC03vpRe36mDOkM-OluIvo4tJmgOLBXvY2jpl5kuCwFlnqTZTPMmR0EPFpZVDc_Y0SZMeQtitKqZZmurEKPptAgS9Hs7ZhAYhZy-LJXSoEoS6r8nVhXwxZenJE3b_62XcnFU4A
      ]]
      local mock_header = {}
      local pem_key = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAn5eMflAv9u5Lguj8FHPS\nlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk/optA8CgH5s7gm\nABfHATJKCJA6gA6Zv/ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df+cr84+\n6HFOyQa/TTybqGv1sGq+kdk+pewISDfKS5k+ehGGok+3FKwKW0FLX8BZK6Edp95R\n7KXeH+WOIO1uXZTgnLVoaR34S9p0gqYQ+wEy3/PjK3dv09D2BgGlxl5NM5lcZaWn\n4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv+/EWEiU6FskrmTMhOH0\nJQIDAQAB\n-----END PUBLIC KEY-----\n"
      mock_header.kid = "some-kid"

      jwt.decode = function()
        return true, mock_header, nil
      end

      spy.on(jwt, 'decode')

      jwks.to_pem = function()
        return pem_key
      end

      local decoded_token, error = jwt.validate_with_jwks(token, jwks_keys)

      assert.spy(jwt.decode).was.called_with(token)
      assert.spy(jwt.decode).was.called_with(token, pem_key, true)
    end)
  end)
end)
