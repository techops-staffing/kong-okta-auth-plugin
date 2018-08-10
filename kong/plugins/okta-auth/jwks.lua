-- This module is based on
-- https://github.com/venkatmarepalli/lua-resty-openidc/blob/7fb07424a83e4fcd853df66e84fac848e7f568d9/lib/resty/openidc.lua

local cjson   = require "cjson"
local b64 = require "mime".b64
local unb64 = require "mime".unb64
-- local kong_cache = require "kong.tools.database_cache"

local M = {}

local b64map = { ['-'] = '+', ['_'] = '/' };
local function unb64url(s)
    return (unb64(s:gsub("[-_]", b64map) .. "=="));
end

local wrap = ('.'):rep(64);
local envelope = "-----BEGIN %s-----\n%s\n-----END %s-----\n"

function truncate(x)
   return x<0 and math.ceil(x) or math.floor(x)
end

local function der2pem(data, header, typ)
  typ = typ:upper() or "CERTIFICATE";
  if header == nil then
    data = b64(data);
    return string.format(envelope, typ, data:gsub(wrap, '%0\n', ((#data-1)/64)), typ);
  else
    data = header .. b64(data)
    position = truncate((#data-1)/64)
    gsubed_data, num = data:gsub(wrap, '%0\n', position, typ)

    return string.format(envelope, typ, gsubed_data, typ);
  end
end

local function encode_length(length)
    if length < 0x80 then
        return string.char(length);
    elseif length < 0x100 then
        return string.char(0x81, length);
    elseif length < 0x10000 then
        return string.char(0x82, math.floor(length/0x100), length%0x100);
    end
    error("Can't encode lengths over 65535");
end

local function encode_sequence(array, of)
    local encoded_array = array;
    if of then
        encoded_array = {};
        for i = 1, #array do
            encoded_array[i] = of(array[i]);
        end
    end
    encoded_array = table.concat(encoded_array);

    return string.char(0x30) .. encode_length(#encoded_array) .. encoded_array;
end

local function encode_binary_integer(bytes)
    if bytes:byte(1) > 128 then
        bytes = "\0" .. bytes;
     end
     return "\2" .. encode_length(#bytes) .. bytes;
end

local function encode_sequence_of_integer(array)
  return encode_sequence(array,encode_binary_integer);
end

local function encode_string(str, typ)
  if str:byte(1) > 128 then str = "\0" .. str; end
  return string.char(typ) .. encode_length(#str) .. str;
end

local function encode_bit_string(str)
  return encode_string(str, 0x03);
end

local function get_jwk (keys, kid)
  for _, value in pairs(keys) do
    if value.kid == kid then
      return value
    end
  end

  return nil
end

local function is_url(str)
  return string.match(str, "http")
end

local function fetch_jwks(key_url)
  local https = require "ssl.https"
  return https.request(key_url)
end

local function cache(key, kid)
  local value = kong_cache.get(kid)

  if value == nil then
    value = fetch_jwks(key)
    kong_cache.set(kid, key)
  end

  return value
end

function M.to_pem(key, kid)
  --local key = cache(key, kid)
  local key = fetch_jwks(key)
  local jwks = cjson.decode(key)

  local algorithms = {
    RSA = {
      OID = "\006\009\042\134\072\134\247\013\001\001\001";
      field_order = { 'n', 'e', 'd', 'p', 'q', 'dp', 'dq', 'qi', };
      start = { "\0" };
      parameters = "\5\0";
    };
  };

  local kty = get_jwk(jwks.keys, kid).kty;
  local info = assert(algorithms[kty], "Unsupported key type");
  local der_key = {};
  local e = get_jwk(jwks.keys,kid).e;

  table.insert(der_key, unb64url(get_jwk(jwks.keys,kid).n));
  table.insert(der_key, unb64url(get_jwk(jwks.keys,kid).e));

  local encoded_key = encode_sequence_of_integer(der_key);
  local pem_key = der2pem(encoded_key,"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A","PUBLIC KEY")
  print("---------- PEM KEY --------------------")
  print(pem_key)
  return pem_key
end

return M
