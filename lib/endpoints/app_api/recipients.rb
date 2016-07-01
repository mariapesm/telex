require_relative "../../mediators/recipients/errors"

module Endpoints
  class AppAPI::Recipients < Base
    namespace "/apps" do
      before do
        content_type :json, charset: 'utf-8'
      end
      
      error Mediators::Recipients::Forbidden do
        status 403
      end

      error Mediators::Recipients::NotFound do
        status 404
      end

      get "/:app_id" do |app_id|
        recipients = Mediators::Recipients::Lister.run(app_id: app_id, heroku_client: heroku_client)
        respond(recipients.map { |r| project_recipient(r) })
      end

      post "/:app_id/recipients" do |app_id|
        recipient = Mediators::Recipients::Creator.run(
          heroku_client: heroku_client,
          app_id: app_id,
          email: data.fetch("email"),
          callback_url: data.fetch("callback_url")
        )
        status 201
        respond_json(project_recipient(recipient))
      end

      put "/:app_id/recipients/:id/verify" do |app_id, id|
        Mediators::Recipient::Verifier.run(
          heroku_client: heroku_client,
          recipient: get_recipient(app_id: app_id, id: id),
          token: data.fetch("token")
        )
        status 204
      end

      patch "/:app_id/recipients/:id" do |app_id, id|
        recipient = Mediators::Recipient::Updater.run(
          heroku_client: heroku_client,
          recipient: get_recipient(app_id: app_id, id: id),
          active: data.fetch("active"),
          callback_url: data.fetch("callback_url")
        )
        respond_json(project_recipient(recipient))
      end

      delete "/:app_id/recipients/:id" do |app_id, id|
        Mediators::Recipient::Deleter.run(
          heroku_client: heroku_client,
          recipient: get_recipient(app_id: app_id, id: id)
        )
        status 204
      end

    private
      def project_recipient(recipient)
        { id: recipient.id, verification_url: recipient.verification_url }
      end

      def get_recipient(app_id:, id:)
        raise Pliny::Errors::UnprocessableEntity unless id =~ Pliny::Middleware::RequestID::UUID_PATTERN
        raise Pliny::Errors::UnprocessableEntity unless app_id =~ Pliny::Middleware::RequestID::UUID_PATTERN
        recipient = ::Recipient[app_id: app_id, id: id]
        raise Pliny::Errors::NotFound unless recipient
        recipient
      end
    end
  end
end
