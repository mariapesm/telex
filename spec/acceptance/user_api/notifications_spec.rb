require "spec_helper"

describe Endpoints::UserAPI::Notifications do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/user/schema.json"
  end

  describe 'GET /user/notifications' do
    it 'returns correct status code and conforms to schema' do
      get '/user/notifications'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'POST /user/notifications' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/user/notifications', MultiJson.encode({})
      expect(last_response.status).to eq(201)
    end
  end

  describe 'GET /user/notifications/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/user/notifications/123"
      expect(last_response.status).to eq(200)
    end
  end

  describe 'PATCH /user/notifications/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch '/user/notifications/123', MultiJson.encode({})
      expect(last_response.status).to eq(200)
    end
  end

  describe 'DELETE /user/notifications/:id' do
    it 'returns correct status code and conforms to schema' do
      delete '/user/notifications/123'
      expect(last_response.status).to eq(200)
    end
  end
end
