require 'kong'
require 'httparty'

describe 'plugin' do
  okta_base_url = ENV['OKTA_BASE_URL']
  auth_server_id = ENV['OKTA_AUTH_SERVER_ID']
  unkonwn_auth_server_id = ENV['OKTA_UNKONWN_AUTH_SERVER_ID']
  client_id = ENV['OKTA_CLIENT_ID']
  client_secret = ENV['OKTA_CLIENT_SECRET']
  basic_token = ENV['OKTA_BASIC_TOKEN']
  expired_token = ENV['EXPIRED_TOKEN']

  before(:all) do
    existing_api = Kong::Api.find_by_name('api')
    existing_api.delete unless existing_api.nil?

    api = Kong::Api.new({
      name: 'api',
      uris: ['/api'],
      upstream_url: 'https://mockbin.com'
    })
    api.create
    plugin = Kong::Plugin.new({
      api_id: api.id,
      name: 'okta-auth',
      config: {
        authorization_server: "#{okta_base_url}/oauth2/#{auth_server_id}",
        client_id: client_id,
        client_secret: client_secret
      }
    })
    plugin.create
  end

  context 'when the token is valid' do
    let!(:access_token) do
      access_token_url = "#{okta_base_url}/oauth2/#{auth_server_id}/v1/token"
  
      response = HTTParty.post(access_token_url,
        headers: { authorization: "Basic #{basic_token}" },
        body: 'grant_type=client_credentials&scope=api'
      )
  
      response['access_token']
    end

    it 'returns 200' do
      response = HTTParty.get(
        'http://localhost:8000/api',
        headers: {
          authorization: "Bearer #{access_token}"
        }
      )

      expect(response.code).to eql(200)
    end
  end

  context 'when the token is not sent' do
    it 'returns a 401' do
      response = HTTParty.get('http://localhost:8000/api')

      expect(response.code).to eql(401)
    end
  end

  context 'when the token is malformed' do
    it 'returns a 401' do
      invalid_token = "eyUY0xuLU5VUTJEM1RpVFFZSExpSy1pRktlSElzIiwiYWxnIjoiUlMyNTYifQ.eyJ2ZXIiOjEsImp0aSI6IkFULmJBR25xbUI1SkZnSlJCMUVwUXZqemJ6dFRBMXpTVFBXbzlrMnhNS3dHSnMiLCJpc3MiOiJodHRwczovL2Rldi01NTUyNTkub2t0YXByZXZpZXcuY29tL29hdXRoMi9hdXNlM3l0NXVkNDZKZXd3cTBoNyIsImF1ZCI6IlBsYXRmb3JtIiwiaWF0IjoxNTE5ODM0NTk5LCJleHAiOjE1MTk4MzgxOTksImNpZCI6IjBvYWUzeWloYmhrZGRTMTNmMGg3Iiwic2NwIjpbImFwaV9zY29wZSJdLCJzdWIiOiIwb2FlM3lpaGJoa2RkUzEzZjBoNyJ9.hEeKN04XBiR70Z2i_0lo5e9hEs4YeHMxW9E6nxKRL9K6KkGf-wWhT9ENp_Yt_r1E6RyiQoHMfBjgu8gibFqLtqCG_tmcm3dBPKSk2H0yDsK9yNDvF4GeConT0Q7kqwrJFtud15vHbcpplQscJZrGuuUsfdHqcBXD4Qu9PTJpvwyc8WNuokqdeCqke71OgxNmOjp5hWvh5FlkSve_3pdMcIp4kX_uppIAZVdN6xcyxDnViNbLp_GDJSQlpczv61sSvDSEfnjQF268D2-Sq8g0CGfgRl-MmSfEtb5iXywCI-82Az-O9nzmlDierc8cLEqd0msep-a-5huPZtnPAaDNXA"
      response = HTTParty.get(
        'http://localhost:8000/api',
        headers: {
          authorization: "Bearer #{invalid_token}"
        }
      )

      expect(response.code).to eql(401)
    end
  end

  context 'when the token is expired' do
    it 'returns a 401' do
      response = HTTParty.get(
        'http://localhost:8000/api',
        headers: {
          authorization: "Bearer #{expired_token}"
        }
      )

      expect(response.code).to eql(401)
    end
  end

  context 'when the token is from another authorization server' do
    let!(:access_token) do
      access_token_url = "#{okta_base_url}/oauth2/#{unkonwn_auth_server_id}/v1/token"
  
      response = HTTParty.post(access_token_url,
        headers: { authorization: "Basic #{basic_token}" },
        body: 'grant_type=client_credentials&scope=api'
      )
  
      response['access_token']
    end

    it 'returns a 401' do
      response = HTTParty.get(
        'http://localhost:8000/api',
        headers: {
          authorization: "Bearer #{access_token}"
        }
      )

      expect(response.code).to eql(401)
    end
  end
end
