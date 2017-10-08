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
    }
  }
}
