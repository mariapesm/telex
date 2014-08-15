module Endpoints
  class Producer::Messages < Base
    namespace "/messages" do
      before do
        content_type :json, charset: 'utf-8'
      end

      post do
        status 201
        "{}"
      end

    end
  end
end
