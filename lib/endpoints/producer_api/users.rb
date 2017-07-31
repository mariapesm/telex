module Endpoints
  class ProducerAPI::Users < Base
    namespace "/apps/:app_id/users" do
      before do
        unless params[:app_id] =~ Pliny::Middleware::RequestID::UUID_PATTERN
          raise Pliny::Errors::UnprocessableEntity
        end
        authorized!
        content_type :json, charset: 'utf-8'
      end

      get do
        users_with_roles = Mediators::Messages::AppUserFinder.run(target_id: params[:app_id])
        respond_json(users_with_roles)
      end

      private
      def authorized!
        halt 403 unless authorized?
      end

      def authorized?
        # for now only allow the logdrain-remediation app to access this endpoint
        current_producer && current_producer.name == 'logdrain-remediation'
      end

      def current_producer
        Pliny::RequestStore.store.fetch(:current_producer)
      end

      def respond_json(users)
        sz = Serializers::ProducerAPI::UserWithRoleSerializer.new(:default)
        encode(sz.serialize(users))
      end
    end
  end
end
