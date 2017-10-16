# Kong Okta Auth Plugin

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
