require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Producer::Messages  end

  describe "GET /messages" do
    it "succeeds" do
      get "/messages"
      expect(last_response.status).to eq(200)
    end
  end
end
