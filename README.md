# Kong Okta Auth Plugin

Kong Plugin to validate OAuth 2.0 access tokens against an OKTA Authorization Server. The validation is made using [OKTA's introspection endpoint](https://developer.okta.com/docs/api/resources/oauth2.html#introspection-request).

When enabled, this plugin will validate the token and add new headers to requests based on the claims in the provided JWT token. The generated headers follow the naming convention of HTTP-OKTA-<claim-name>. The following headers will be included in the request to the APIs:
- OKTA-Group
- OKTA-Scope
- OKTA-Username
