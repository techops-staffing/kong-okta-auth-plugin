local errors = require "kong.dao.errors"
local okta_api = require "kong.plugins.okta-auth.okta_api"
return {
  no_consumer = false,
  fields = {
    client_id = {
      type = "string",
      required = true,
    },
    client_secret = {
      type = "string",
      required = true,
    },
    authorization_server = {
      type = "string",
      required = true,
    },
    api_version = {
      type = "string",
      default = "v1",
      required = false,
    },
    check_auth_server = {
      type = "boolean",
      default = true,
      required = false,
    }
  },
  self_check = function(schema, conf, dao, is_updating)
    if conf.check_auth_server then
      response_body = okta_api.introspect(
        conf.authorization_server,
        conf.api_version,
        conf.client_id,
        conf.client_secret,
        "token"
      )

      if not response_body then
        return false, errors.schema(
          "Could not access authorization server ("..
          conf.authorization_server..
          ") with the specified configuration"
        )
      end
    end
    return true
  end
}
