require 'net/http'
require 'uri'
require 'json'

def send_loopback_request
  uri = URI.parse("http://#{ENV['KONG_ADMIN_LISTEN']}/apis")

  header = { 'Content-Type' => 'text/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)

  request.set_form_data(
    name: 'admin-api',
    upstream_url: "http://#{ENV['KONG_ADMIN_LISTEN']}",
    uris: '/admin-api'
  )

  http.request(request)
end

def send_auth_plugin_request
  uri = URI.parse("http://#{ENV['KONG_ADMIN_LISTEN']}/apis/admin-api/plugins")
  header = { 'Content-Type' => 'text/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)

  request.set_form_data(
    name: 'key-auth',
    'config.hide_credentials' => true
  )

  http.request(request)
end

def send_logging_plugin_request
  uri = URI.parse("http://#{ENV['KONG_ADMIN_LISTEN']}/plugins")
  header = { 'Content-Type' => 'text/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)

  request.set_form_data(
    name: 'http-log',
    'config.http_endpoint' => "#{ENV['KONG_LOGGING_ENDPOINT']}"
  )

  http.request(request)
end

def send_consumer_request
  uri = URI.parse("http://#{ENV['KONG_ADMIN_LISTEN']}/consumers")
  header = { 'Content-Type' => 'text/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)

  request.set_form_data(
    username: 'adminapi'
  )

  http.request(request)
end

def send_provision_key_request
  uri = URI.parse("http://#{ENV['KONG_ADMIN_LISTEN']}/consumers/adminapi/key-auth")
  header = { 'Content-Type' => 'text/json' }
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, header)

  request.set_form_data(
    key: "#{ENV['KONG_ADMIN_API_KEY']}"
  )

  http.request(request)
end

def request_works?(response)
  http_success_code = 201
  http_already_exists_code = 409
  response_code = response.code.to_i

  response_code == http_success_code ||
    response_code == http_already_exists_code
end

def execute_request(request_fn, label)
  puts "Executing #{label}..."
  response = send(request_fn)

  if request_works?(response)
    puts "#{label} success!"
  else
    puts "#{label} fails! Code: #{response.code}, Body: #{response.body}"
    exit 1
  end
end

execute_request('send_loopback_request', 'Setting loopback')
execute_request('send_auth_plugin_request', 'Setting key auth')
execute_request('send_consumer_request', 'Setting consumer')
execute_request('send_provision_key_request', 'Setting key provision')
execute_request('send_logging_plugin_request', 'Setting logging')
