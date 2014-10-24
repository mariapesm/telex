module Middleware
  class UserAuthenticator
    def initialize(app)
      @app = app
    end

    def call(env)
      auth = Rack::Auth::Basic::Request.new(env)
      unless auth.provided? && auth.basic? && auth.credentials
        raise Pliny::Errors::Unauthorized
      end

      _, api_key = auth.credentials

      user = lookup_user(api_key)

      unless user
        raise Pliny::Errors::Unauthorized
      end

      Pliny::RequestStore.store[:current_user] = user
      @app.call(env)
    end

    private

    def lookup_user(key)
      return nil unless key =~ /\A[a-z0-9-]+\z/

      client = Telex::HerokuClient.new(api_key: key)
      user_response = client.account_info

      find_or_create_user(
        heroku_id: user_response.fetch('id'),
        email:     user_response.fetch('email')
      )
    rescue Excon::Errors::Error
      nil
    end

    def find_or_create_user(heroku_id:, email:)
      user = User[heroku_id: heroku_id]
      unless user
        user = User.create(heroku_id: heroku_id, email: email)
      end
      user
    end

  end
end
