require_relative "../../mediators/recipients/errors"

module Endpoints
  class AppAPI::Recipients < Base
    namespace "/:app_id" do
      before do
        authorized!
        content_type(:json)

        @app_info = get_app_info
      end

      error Excon::Errors::Forbidden do
        status 403
      end

      error Mediators::Recipients::NotFound, Excon::Errors::NotFound, Pliny::Errors::NotFound do
        status 404
      end

      error Mediators::Recipients::LimitError do
        status 429
        { "id": "bad_request", "message": sinatra_error.message }.to_json
      end

      error MultiJson::ParseError, Sequel::ValidationFailed, Sequel::UniqueConstraintViolation, Mediators::Recipients::BadRequest do
        status 400
        { "id": "bad_request", "message": bad_request_message }.to_json
      end

      get "/recipients" do
        recipients = Mediators::Recipients::Lister.run(app_info: @app_info)
        respond_json(recipients)
      end

      post "/recipients" do
        recipient = Mediators::Recipients::Creator.run(
          app_info: @app_info,
          email: data.fetch("email", ""),
          title: data.fetch("title", ""),
          body: data.fetch("body", ""),
          template: data.fetch("template", ""),
        )
        status 201
        respond_json(recipient)
      end

      put "/recipients/:id/verify" do
        Mediators::Recipients::Verifier.run(
          recipient: get_recipient,
          token: data.fetch("token", ""),
        )
        status 204
      end

      patch "/recipients/:id" do
        recipient = Mediators::Recipients::Updater.run(
          app_info: @app_info,
          recipient: get_recipient,
          active: data.fetch("active", false),
          title: data.fetch("title", ""),
          body: data.fetch("body", ""),
          template: data.fetch("template", ""),
        )
        respond_json(recipient)
      end

      delete "/recipients/:id" do
        Mediators::Recipients::Deleter.run(
          recipient: get_recipient
        )
        status 204
      end

    private
      def authorized!
        halt 403 unless authorized?
      end

      def authorized?
        heroku_client.capable?(id: params[:app_id], type: "app", capability: "manage_alerts")
      end

      def heroku_client
        Pliny::RequestStore.store.fetch(:heroku_client)
      end

      def respond_json(recipient_or_recipients)
        sz = Serializers::AppAPI::RecipientSerializer.new(:default)
        encode(sz.serialize(recipient_or_recipients))
      end

      def get_recipient
        raise Pliny::Errors::UnprocessableEntity unless params[:app_id] =~ Pliny::Middleware::RequestID::UUID_PATTERN
        raise Pliny::Errors::UnprocessableEntity unless (params[:id]) =~ Pliny::Middleware::RequestID::UUID_PATTERN

        Recipient[app_id: params[:app_id], id: params[:id], deleted_at: nil] || raise(Pliny::Errors::NotFound)
      end

      def get_app_info
        heroku_client.app_info(params[:app_id], base_headers_only: true)
      end

      def sinatra_error
        env['sinatra.error']
      end

      def bad_request_message
        case sinatra_error
        when MultiJson::ParseError
          "Unable to parse the JSON request"
        when Sequel::UniqueConstraintViolation
          "A recipient with that email already exists"
        when Sequel::ValidationFailed, Mediators::Recipients::BadRequest
          sinatra_error.message
        end
      end
    end
  end
end
