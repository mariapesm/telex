require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Producer::Messages  end

  describe "POST /messages" do
    before do
      @message_body = {
        title: 'Congratulations',
        body: 'You are a winner',
        target: {type: 'user', id: 'whatever'}
      }
    end

    it "succeeds" do
      post "/messages", MultiJson.encode(@message_body)
      expect(last_response.status).to eq(201)
    end
  end
end
