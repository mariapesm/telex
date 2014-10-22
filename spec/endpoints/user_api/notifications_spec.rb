require "spec_helper"

describe Endpoints::UserAPI::Notifications do
  include Rack::Test::Methods

  describe "GET /user/notifications" do
    it "succeeds" do
      get "/notifications"
      expect(last_response.status).to eq(200)
    end
  end
end
