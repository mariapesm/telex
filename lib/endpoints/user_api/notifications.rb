module Endpoints
  class UserAPI::Notifications < Base
    namespace "/notifications" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        notes = Mediators::Notifications::Lister.run(user: current_user)
        sz = Serializers::UserAPI::NotificationSerializer.new(:default)
        encode(sz.serialize(notes))
      end

      patch '/:id' do |id|
        raise Pliny::Errors::BadRequest unless id =~ Pliny::Middleware::RequestID::UUID_PATTERN
        note = ::Notification[id: id, user_id: current_user.id]
        raise Pliny::Errors::NotFound unless note
      end
    end

    private

    def current_user
      Pliny::RequestStore.store.fetch(:current_user)
    end

  end
end
