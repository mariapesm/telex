require_relative "../../mediators/recipients/errors"

module Endpoints
  class AppAPI::Recipients < Base
    before do
      content_type :json, charset: 'utf-8'
    end
    
    error Mediators::Recipients::NotFound do
      status 404
    end

    error MultiJson::ParseError, KeyError, Sequel::ValidationFailed, Sequel::UniqueConstraintViolation do
      status 400
    end

    get "/:app_id/recipients" do |app_id|
      authorize!(app_id: app_id)

      recipients = Mediators::Recipients::Lister.run(app_info: @app_info)
      respond_json(recipients)
    end

    post "/:app_id/recipients" do |app_id|
      authorize!(app_id: app_id)

      recipient = Mediators::Recipients::Creator.run(
        app_info: @app_info,
        email: data.fetch("email"),
        callback_url: data.fetch("callback_url")
      )
      status 201
      respond_json(recipient)
    end

    put "/:app_id/recipients/:token/verify" do |app_id, token|
      authorize!(app_id: app_id)

      Mediators::Recipients::Verifier.run(
        recipient: get_recipient(app_id: app_id, token: token),
      )
      status 204
    end

    patch "/:app_id/recipients/:id" do |app_id, id|
      authorize!(app_id: app_id)

      recipient = Mediators::Recipients::Updater.run(
        app_info: @app_info,
        recipient: get_recipient(app_id: app_id, id: id),
        active: data.fetch("active", false),
        callback_url: data.fetch("callback_url", "")
      )
      respond_json(recipient)
    end

    delete "/:app_id/recipients/:id" do |app_id, id|
      authorize!(app_id: app_id)

      Mediators::Recipients::Deleter.run(
        recipient: get_recipient(app_id: app_id, id: id)
      )
      status 204
    end

  private
    def authorize!(app_id:)
      halt 403 unless @app_info = fetch_app_info(app_id: app_id)
    end

    def heroku_client
      Pliny::RequestStore.store.fetch(:heroku_client)
    end

    def respond_json(recipient_or_recipients)
      sz = Serializers::AppAPI::RecipientSerializer.new(:default)
      encode(sz.serialize(recipient_or_recipients))
    end

    def get_recipient(app_id:, id: nil, token: nil)
      raise Pliny::Errors::UnprocessableEntity unless app_id =~ Pliny::Middleware::RequestID::UUID_PATTERN
      raise Pliny::Errors::UnprocessableEntity unless (id || token) =~ Pliny::Middleware::RequestID::UUID_PATTERN

      recipient = if id
        Recipient[app_id: app_id, id: id]
      elsif token
        Recipient.find_by_app_id_and_verification_token(app_id: app_id, verification_token: token)
      end

      recipient || raise(Pliny::Errors::NotFound)
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
