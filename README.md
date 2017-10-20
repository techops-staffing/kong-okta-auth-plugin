# Kong Okta Auth Plugin

[![Build Status](https://travis-ci.org/techops-staffing/kong-okta-auth-plugin.svg?branch=master)](https://travis-ci.org/techops-staffing/kong-okta-auth-plugin)

Kong Plugin to validate OAuth 2.0 access tokens against an OKTA Authorization Server. The validation is made using [OKTA's introspection endpoint](https://developer.okta.com/docs/api/resources/oauth2.html#introspection-request).

When enabled, this plugin will validate the token and add new headers to requests based on the data in the provided JWT token. The generated headers follow the naming convention of OKTA-\<field-name\>.

The headers *OKTA-Group*, *OKTA-Scope* and *OKTA-Username* will be included with requests to APIs.

### Example

JWT payload:
```
{
  "ver": 1,
  "iss": "https://okta.com/oauth2/auth-server-id",
  "aud": "https://api.com",
  "iat": 1507122921,
  "exp": 1508203412,
  "cid": "cid",
  "uid": "uid",
  "scp": [
    "read",
    "write"
  ],
  "sub": "user@example.com",
  "group": [
    "Everyone"
  ]
}
```

Headers included with request:  
```
OKTA-Group: "Everyone"
OKTA-Scope: "read write"
OKTA-Username : "user@example.com"
```

## Enabling Plugin

You can enable Okta-Auth plugin for an api with the following request:

```bash
curl -X POST http://localhost:8001/apis/example-api/plugins \
  --data "name=okta-auth" \
  --data "config.authorization_server=https://okta.com/oauth2/auth-server-id" \
  --data "config.client_id=cid" \
  --data "config.client_secret=secret" \
  --data "config.api_version=v1" \
  --data "config.check_auth_server=true"
```

Parameters description:

form parameter|required|description
---|---|---
`name` | *required* | Plugin name: `okta-auth`
`authorization_server` | *required* | Okta authorization server URL
`client_id` | *required*| Okta's public identifier for the client
`client_secret` | *required* | Okta's client secret
`api_version` | *optional* | Okta's authorization server API version (default: `v1`)
`check_auth_server` | *optional* | If *true* check authorization server availability (default: `true`)


