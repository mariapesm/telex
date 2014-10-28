module Endpoints
  class UserAPI::Notifications < Base
    namespace "/notifications" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        current_user
        encode([])
      end

    end

    private

    def current_user
      Pliny::RequestStore.store.fetch(:current_user)
    end

  end
end
