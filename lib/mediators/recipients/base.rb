module Mediators::Recipients
  class Base < Mediators::Base
    attr_reader :heroku_client, :app_id, :email, :callback_url, :recipient, :app_info, :active

    def initialize(heroku_client:, app_id:, email: nil, callback_url:, active: false, recipient: nil)
      @heroku_client = heroku_client
      @app_id = app_id
      @email = email
      @active = active
      @callback_url = callback_url
      @recipient = recipient
    end

    def authorize!
      raise Forbidden unless authorized?
    end

    # TODO: figure out a better way to determine permissions. Does this require to add
    # a new role thing in API or is this good enough?
    def authorized?
      @app_info = heroku_client.app_info(app_id)
    rescue Excon::Errors::Forbidden, Telex::HerokuClient::NotFound
    rescue => err
      $stderr.puts "Mediators::Recipients::Creator::authorized? : Unknown exception: %s" % err.inspect
    end
  end
end
