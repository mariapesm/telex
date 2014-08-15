module Endpoints
  class Producer::Messages < Base
    namespace "/messages" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        "[]"
      end

      post do
        status 201
        "{}"
      end

      get "/:id" do
        "{}"
      end

      patch "/:id" do |id|
        "{}"
      end

      delete "/:id" do |id|
        "{}"
      end
    end
  end
end
