require "spec_helper"

describe Endpoints::UserAPI::Notifications do
  include Rack::Test::Methods

  before do
    @user = Fabricate(:user)
    Pliny::RequestStore.store[:current_user] = @user
  end

  describe "GET /user/notifications" do
    it "succeeds" do
      get "/notifications"
      expect(last_response.status).to eq(200)
    end
  end

  describe "PATCH /user/notifications" do
    it "can set read to now" do
      note = Fabricate(:notification, user: @user, read_at: nil)
      patch "/notifications/#{note.id}", MultiJson.dump({read: true})
      expect(last_response.status).to eq(200)
      note.reload
      expect(note.read_at).to_not be_nil
    end

    it "can set read to nil" do
      note = Fabricate(:notification, user: @user, read_at: Time.now)
      patch "/notifications/#{note.id}", MultiJson.dump({read: false})
      expect(last_response.status).to eq(200)
      note.reload
      expect(note.read_at).to be_nil
    end
  end
end
