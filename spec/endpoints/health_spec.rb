require "spec_helper"

describe Endpoints::Health do
  include Rack::Test::Methods

  describe "GET /health" do
    it "renders a 200 when all is good" do
      get "/health"
      expect(last_response.status).to eq(200)
    end

    it "renders a 503 on database errors" do
      allow(User.db).to receive(:execute) { raise Sequel::DatabaseError }
      get "/health"
      expect(last_response.status).to eq(503)
    end
  end
end
