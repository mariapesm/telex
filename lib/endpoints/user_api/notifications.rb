module Endpoints
  class UserAPI::Notifications < Base
    namespace "/notifications" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode([])
      end

      post do
        status 201
        encode({})
      end

      get "/:id" do
        encode({})
      end

      patch "/:id" do |id|
        encode({})
      end

      delete "/:id" do |id|
        encode({})
      end
    end
  end
end
