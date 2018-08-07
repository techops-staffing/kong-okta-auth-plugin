local jwt = require "kong.plugins.okta-auth.jwt"
local jwks = require "kong.plugins.okta-auth.jwks"

local jwks_keys = [[
{"keys":[{"alg":"RS256","e":"AQAB","n":"n5eMflAv9u5Lguj8FHPSlLnmMBG3XAtWhq3PbugGw2RrHVEfJ0oMIM6XAX9yaGC9y46wuk_optA8CgH5s7gmABfHATJKCJA6gA6Zv_ol1SObGFnDos9oVpj4Zi7XjVmb39UjRtJtS2S6Df-cr84-6HFOyQa_TTybqGv1sGq-kdk-pewISDfKS5k-ehGGok-3FKwKW0FLX8BZK6Edp95R7KXeH-WOIO1uXZTgnLVoaR34S9p0gqYQ-wEy3_PjK3dv09D2BgGlxl5NM5lcZaWn4Ehs8HvLcIPeAGGA1QcZg3AlgTeGeBVNtsozz4f2MzbGv-_EWEiU6FskrmTMhOH0JQ","kid":"Twfk2D3tYY-xo61vDoRnHdcnERqdQz-xR2zRHHja3Hk","kty":"RSA","use":"sig"},{"alg":"RS256","e":"AQAB","n":"zTsIHUnehKVJjFPu4c8hoLsy-PwANzGDeDPJN6W5wHwjUz_4yGz7_THbCOD5v2hKWYh02qWTqfCmvFaKykjif-6Ofsl1VCLR52pN2o53Sdhr0GFBTU1pWrxh7LyAH3hIqMmv2gWW_dwoF8s-LM3Mwz0bQJ_U3rzR0ToN6aTvbNogwS4cV1hlDMCMYaHXe7XFF9X-TY6Rk1BsJvg0wYtKEopCQIPVGlU8-4GjQHZdEhyGJacAx0WxwYnbIsRsyVgY_FNa91zeX7Ck3F2vB556dMLVpBN8pvi4ADWloDBDVJpYg39SH_roT1hbXDc3i_eBrC50deb0nttlqZWIlbTSeQ","kid":"DhQQVMtmiH9S-68kW0PLMpEJFXgj-zxXfPcRH622Xeg","kty":"RSA","use":"sig"}]}
]]

describe("main", function()
  describe("when token is invalid", function()
    it("returns an error", function()
      local token = [[
      eyJraWQiOiJUd2ZrMkQzdFlZLXhvNjF2RG9SbkhkY25FUnFkUXoteFIyelJISGphM0hrIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULlhtVmt0T0VJQndlUE9oMXNhSGVqNUhhT1l1LV9IN3RYMWpuVkFjTVBEeFEiLCJpc3MiOiJodHRwczovL2Rldi0zOTU3NTYub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNmYWZsbmVkaFNUU3A5WjBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTMyNDUyMDM4LCJleHAiOjE1MzI0NTU2MzgsImNpZCI6IjBvYWZmeHNjbm5sMHNmVXYzMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2FmZnhzY25ubDBzZlV2MzBoNyJ9.QdA9RHEVeg2vNbI3tD_N2TD-IyBRXxc-1j56Ksm1go5RZ2H8QnE39-lZMRDinPZNx6h_Xv213YMhu3QmCuPXWASbu6VWRkeXdKX1bgj3MS4kH0264jOZ5ScwlYB5-49AUx7qhg9ZRp83HIbM3wpSl8S_HoR2S1poCKZIBvFv9MZ2NLCtjRR95n2d7gGCRuGo05Xn22mzAXBqcAo_LC03vpRe36mDOkM-OluIvo4tJmgOLBXvY2jpl5kuCwFlnqTZTPMmR0EPFpZVDc_Y0SZMeQtitKqZZmurEKPptAgS9Hs7ZhAYhZy-LJXSoEoS6r8nVhXwxZenJE3b_62XcnFU4A
      ]]
      local decoded_token, error = jwt.validate_with_jwks(token, jwks_keys)

      assert.is_not_nil(error)
    end)
  end)

  describe("when token is valid", function()
    it("returns decoded token", function()
      local token = [[
      eyJraWQiOiJUd2ZrMkQzdFlZLXhvNjF2RG9SbkhkY25FUnFkUXoteFIyelJISGphM0hrIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULlhtVmt0T0VJQndlUE9oMXNhSGVqNUhhT1l1LV9IN3RYMWpuVkFjTVBEeFEiLCJpc3MiOiJodHRwczovL2Rldi0zOTU3NTYub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNmYWZsbmVkaFNUU3A5WjBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTMyNDUyMDM4LCJleHAiOjE1MzI0NTU2MzgsImNpZCI6IjBvYWZmeHNjbm5sMHNmVXYzMGg3Iiwic2NwIjpbImFwaSJdLCJzdWIiOiIwb2FmZnhzY25ubDBzZlV2MzBoNyJ9.QdA9RHEVeg2vNbI3tD_N2TD-IyBRXxc-1j56Ksm1go5RZ2H8QnE39-lZMRDinPZNx6h_Xv213YMhu3QmCuPXWASbu6VWRkeXdKX1bgj3MS4kH0264jOZ5ScwlYB5-49AUx7qhg9ZRp83HIbM3wpSl8S_HoR2S1poCKZIBvFv9MZ2NLCtjRR95n2d7gGCRuGo05Xn22mzAXBqcAo_LC03vpRe36mDOkM-OluIvo4tJmgOLBXvY2jpl5kuCwFlnqTZTPMmR0EPFpZVDc_Y0SZMeQtitKqZZmurEKPptAgS9Hs7ZhAYhZy-LJXSoEoS6r8nVhXwxZenJE3b_62XcnFU4A
      ]]
      local mock_header = {}
      mock_header.kid = "some-kid"

      jwt.decode = function()
        return true, mock_header, nil
      end

      jwks.to_pem = function()
        return ""
      end

      local decoded_token, error = jwt.validate_with_jwks(token, jwks_keys)

      assert.is_nil(error)
      assert.is_not_nil(decoded_token)
    end)
  end)
end)
