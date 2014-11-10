module Endpoints
  class UserAPI::Notifications < Base
    namespace "/notifications" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        notes = Mediators::Notifications::Lister.run(user: current_user)
        respond_json(notes)
      end

      patch '/:id' do |id|
        note = Mediators::Notifications::ReadStatusUpdater.run(notification: get_note(id), read_status: get_status)
        respond_json(note)
      end
    end

    private

    def respond_json(note_or_notes)
      sz = Serializers::UserAPI::NotificationSerializer.new(:default)
      encode(sz.serialize(note_or_notes))
    end

    def current_user
      Pliny::RequestStore.store.fetch(:current_user)
    end

    def get_note(id)
      raise Pliny::Errors::UnprocessableEntity unless id =~ Pliny::Middleware::RequestID::UUID_PATTERN
      note = ::Notification[id: id, user_id: current_user.id]
      raise Pliny::Errors::NotFound unless note
      note
    end

    def get_status
      data.fetch('read')
    rescue KeyError
      raise Pliny::Errors::UnprocessableEntity
    end

  end
end
