module Mediators::Recipients
  class Creator < Mediators::Base
    attr_reader :heroku_client, :app_id, :email, :callback_url

    def initialize(heroku_client:, app_id:, email:, callback_url:)
      @heroku_client = heroku_client
      @app_id = app_id
      @email = email
      @callback_url = callback_url
    end

    def call
      raise "Not authorized" unless authorized?

      Recipient.create(email: email, app_id: app_id, callback_url: callback_url)
    end

    # TODO: we need a way to get the key, probably by hacking into user_authenticator
    # TODO: figure out a better way to determine permissions. Does this require to add
    # a new role thing in API or is this good enough?
    def authorized?
      heroku_client.app_info(app_id)
    rescue Excon::Errors::Forbidden, Telex::HerokuClient::NotFound
    rescue => err
      $stderr.puts "Mediators::Recipients::Creator::authorized? : Unknown exception: %s" % err.inspect
    end
  end
end
