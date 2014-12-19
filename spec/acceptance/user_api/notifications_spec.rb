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

  def login(api_key)
    authorize '', api_key
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
        heroku_user = HerokuAPIMock.create_heroku_user
        login(heroku_user.api_key)
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

  describe 'PATCH /user/notifications/:id' do
    def do_patch(id: @notification.id, body: {read: true})
      patch "/user/notifications/#{id}", MultiJson.encode(body)
    end

    before do
      @heroku_user = HerokuAPIMock.create_heroku_user
      @user = Fabricate(:user, heroku_id: @heroku_user.heroku_id, email: @heroku_user.email)
      @notification = Fabricate(:notification, user: @user)
    end

    context 'with bad creds' do
      it 'returns a 401' do
        do_patch
        expect(last_response.status).to eq(401)
      end
    end

    context 'with good creds' do
      before do
        login(@heroku_user.api_key)
      end

      it "returns a 404 if the notification isn't there" do
        do_patch(id: SecureRandom.uuid)
        expect(last_response.status).to eq(404)
      end

      it "returns a 404 if the notification belongs to someone else" do
        other_note = Fabricate(:notification)
        do_patch(id: other_note.id)
        expect(last_response.status).to eq(404)
      end

      it "returns a 422 if the id is malformed" do
        do_patch(id: 'notauuid')
        expect(last_response.status).to eq(422)
      end

      it 'returns a 200 when everything checks out' do
        do_patch
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe 'GET /user/notifications/:id/read.png' do
    before do
      @notification = Fabricate(:notification)
    end

    it 'returns a 200 for vaild notifications even without auth' do
      get "/user/notifications/#{@notification.id}/read.png"
      expect(last_response.status).to eq(200)
    end

    it 'returns a 404 for invalid notificaitons' do
      get "/user/notifications/#{SecureRandom.uuid}/read.png"
      expect(last_response.status).to eq(404)
    end
  end

end
