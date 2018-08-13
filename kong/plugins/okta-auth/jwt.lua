local cjson  = require 'cjson'
local base64 = require 'base64'
local crypto = require 'crypto'
local jwks = require "kong.plugins.okta-auth.jwks"
local singletons = require "kong.singletons"

local function signRS (data, key, algo)
	local privkey = crypto.pkey.from_pem(key, true)
	if privkey == nil then
		return nil, 'Not a private PEM key'
	else
		return crypto.sign(algo, data, privkey)
	end
end

local function verifyRS (data, signature, key, algo)
	local pubkey = crypto.pkey.from_pem(key)
	if pubkey == nil then
		return nil, 'Not a public PEM key'
	else
		return crypto.verify(algo, data, signature, pubkey)
	end
end

local alg_sign = {
	['HS256'] = function(data, key) return crypto.hmac.digest('sha256', data, key, true) end,
	['HS384'] = function(data, key) return crypto.hmac.digest('sha384', data, key, true) end,
	['HS512'] = function(data, key) return crypto.hmac.digest('sha512', data, key, true) end,
	['RS256'] = function(data, key) return signRS(data, key, 'sha256') end,
	['RS384'] = function(data, key) return signRS(data, key, 'sha384') end,
	['RS512'] = function(data, key) return signRS(data, key, 'sha512') end
}

local alg_verify = {
	['HS256'] = function(data, signature, key) return signature == alg_sign['HS256'](data, key) end,
	['HS384'] = function(data, signature, key) return signature == alg_sign['HS384'](data, key) end,
	['HS512'] = function(data, signature, key) return signature == alg_sign['HS512'](data, key) end,
	['RS256'] = function(data, signature, key) return verifyRS(data, signature, key, 'sha256') end,
	['RS384'] = function(data, signature, key) return verifyRS(data, signature, key, 'sha384') end,
	['RS512'] = function(data, signature, key) return verifyRS(data, signature, key, 'sha512') end
}

local function b64_encode(input)
	local result = base64.encode(input)

	result = result:gsub('+','-'):gsub('/','_'):gsub('=','')

	return result
end

local function b64_decode(input)
	local reminder = #input % 4

	if reminder > 0 then
		local padlen = 4 - reminder
		input = input .. string.rep('=', padlen)
	end

	input = input:gsub('-','+'):gsub('_','/')

	return base64.decode(input)
end

local function tokenize(str, div, len)
	local result, pos = {}, 0

	for st, sp in function() return str:find(div, pos, true) end do

		result[#result + 1] = str:sub(pos, st-1)
		pos = sp + 1

		len = len - 1

		if len <= 1 then
			break
		end
	end

	result[#result + 1] = str:sub(pos)

	return result
end

local M = {}

function M.encode(data, key, alg, header)
	if type(data) ~= 'table' then return nil, "Argument #1 must be table" end
	if type(key) ~= 'string' then return nil, "Argument #2 must be string" end

	alg = alg or "HS256"

	if not alg_sign[alg] then
		return nil, "Algorithm not supported"
	end

	header = header or {}

	header['typ'] = 'JWT'
	header['alg'] = alg

	local segments = {
		b64_encode(cjson.encode(header)),
		b64_encode(cjson.encode(data))
	}

	local signing_input = table.concat(segments, ".")
	local signature, error = alg_sign[alg](signing_input, key)
	if signature == nil then
		return nil, error
	end

	segments[#segments+1] = b64_encode(signature)

	return table.concat(segments, ".")
end

function M.decode(data, key, verify)
	if key and verify == nil then verify = true end
	if type(data) ~= 'string' then return nil, "Argument #1 must be string" end
	if verify and type(key) ~= 'string' then return nil, "Argument #2 must be string" end

	local token = tokenize(data, '.', 3)

	if #token ~= 3 then
		return nil, nil, "Invalid token"
	end

	local headerb64, bodyb64, sigb64 = token[1], token[2], token[3]

	local ok, header, body, sig = pcall(function ()

		return	cjson.decode(b64_decode(headerb64)),
			cjson.decode(b64_decode(bodyb64)),
			b64_decode(sigb64)
	end)

	if not ok then
		return nil, nil, "Invalid json"
	end

	if verify then
		if not header.alg or type(header.alg) ~= "string" then
			return nil, nil, "Invalid alg"
		end

		if body.exp and type(body.exp) ~= "number" then
			return nil, nil, "exp must be number"
		end

		if body.nbf and type(body.nbf) ~= "number" then
			return nil, nil, "nbf must be number"
		end

		if not alg_verify[header.alg] then
			return nil, nil, "Algorithm not supported"
		end

		local verify_result, error
			= alg_verify[header.alg](headerb64 .. "." .. bodyb64, sig, key);
		if verify_result == nil then
			return nil, nil, error
		elseif verify_result == false then
			return nil, nil, "Invalid signature"
		end

		if body.exp and os.time() >= body.exp then
			return nil, nil, "Not acceptable by exp"
		end

		if body.nbf and os.time() < body.nbf then
			return nil, nil, "Not acceptable by nbf"
		end
	end

	return body, header, nil
end

local function get_pem(jwks_str, kid)
	local value, err = singletons.cache:get("kid", nil, jwks.to_pem, jwks_str, kid)

	return value
end

function M.validate_with_jwks(token, jwks_str)
  local decoded_token, decoded_header, error = M.decode(token)

	if(error ~= nil) then
		return nil, error
	end

  local pem_key = get_pem(jwks_str, decoded_header.kid)

  local valid_decoded_token, valid_decoded_header, err = M.decode(token, pem_key, true)

  return valid_decoded_token, err
end

return M
