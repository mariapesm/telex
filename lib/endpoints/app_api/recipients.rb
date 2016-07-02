require_relative "../../mediators/recipients/errors"

module Endpoints
  class AppAPI::Recipients < Base
    namespace "/apps" do
      before do
        content_type :json, charset: 'utf-8'
      end
      
      error Mediators::Recipients::NotFound do
        status 404
      end

      before "/:app_id" do |app_id|
        halt 403 unless @app_info = fetch_app_info(app_id: app_id)
      end

      get "/:app_id" do |app_id|
        recipients = Mediators::Recipients::Lister.run(app_info: @app_info)
        respond(recipients.map { |r| project_recipient(r) })
      end

      post "/:app_id/recipients" do |app_id|
        recipient = Mediators::Recipients::Creator.run(
          app_info: @app_info,
          email: data.fetch("email"),
          callback_url: data.fetch("callback_url")
        )
        status 201
        respond_json(project_recipient(recipient))
      end

      put "/:app_id/recipients/:id/verify" do |app_id, id|
        Mediators::Recipient::Verifier.run(
          app_info: @app_info,
          recipient: get_recipient(app_id: app_id, id: id),
          token: data.fetch("token")
        )
        status 204
      end

      patch "/:app_id/recipients/:id" do |app_id, id|
        recipient = Mediators::Recipient::Updater.run(
          app_info: @app_info,
          recipient: get_recipient(app_id: app_id, id: id),
          active: data.fetch("active"),
          callback_url: data.fetch("callback_url")
        )
        respond_json(project_recipient(recipient))
      end

      delete "/:app_id/recipients/:id" do |app_id, id|
        Mediators::Recipient::Deleter.run(
          app_info: @app_info,
          recipient: get_recipient(app_id: app_id, id: id)
        )
        status 204
      end

    private
      def heroku_client
        Pliny::RequestStore.store.fetch(:heroku_client)
      end

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

      # TODO: figure out a better way to determine permissions. Does this require to add
      # a new role thing in API or is this good enough?
      def fetch_app_info(app_id:)
        heroku_client.app_info(app_id)
      rescue Excon::Errors::Forbidden, Telex::HerokuClient::NotFound
      rescue => err
        $stderr.puts "Mediators::Recipients::Creator::authorized? : Unknown exception: %s" % err.inspect
      end
    end
  end
end
