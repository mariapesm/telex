require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Endpoints::Producer::Messages  end

  describe "POST /messages" do
    def do_post
      post "/messages", MultiJson.encode(@message_body)
    end

    before do
      @producer = Fabricate(:producer)
      Pliny::RequestStore.store[:current_producer] = @producer
      @message_body = {
        title: 'Congratulations',
        body: 'You are a winner',
        target: {type: 'user', id: SecureRandom.uuid}
      }
    end

    context 'with good params' do
      it "succeeds" do
        do_post
        expect(last_response.status).to eq(201)
      end

      it 'creates a message' do
        expect(Message.where(producer_id: @producer.id).count).to eq(0)
        do_post
        expect(Message.where(producer_id: @producer.id).count).to eq(1)
      end

      it "returns the message's id" do
        do_post
        response = MultiJson.decode(last_response.body)
        expect( Message[id: response['id']] ).to_not be_nil
      end
    end

    context 'with bad params' do
      before do
        @message_body[:body] = ''
      end

      it "fails" do
        do_post
        expect(last_response.status).to eq(406)
      end
    end

  end
end
