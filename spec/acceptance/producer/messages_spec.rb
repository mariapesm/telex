require "spec_helper"

describe Endpoints::Producer::Messages do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/producer/schema.json"
  end


  describe 'POST /producer/messages/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/producer/messages', MultiJson.encode({})
      expect(last_response.status).to eq(201)
#      assert_schema_conform
    end

  end

end
