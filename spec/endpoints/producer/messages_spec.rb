require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Producer::Messages  end

  describe "POST /messages" do
    it "succeeds" do
      post "/messages",MultiJson.encode({})
      expect(last_response.status).to eq(201)
    end
  end
end
