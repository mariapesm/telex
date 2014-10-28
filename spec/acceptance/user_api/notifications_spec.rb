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
    def do_get
      get '/user/notifications'
    end

    context 'with bad creds' do
      it 'returns a 401' do
        do_get
        expect(last_response.status).to eq(401)
      end
    end

    context 'with good creds' do
      before do
        @heroku_user = HerokuAPIMock.create_heroku_user
        authorize '', @heroku_user.api_key
      end

      it 'returns a 200' do
        do_get
        expect(last_response.status).to eq(200)
      end

      it 'with no notifications, returns an empty json array' do
        do_get
        expect(MultiJson.decode(last_response.body)).to eq([])
      end
    end

  end
end
