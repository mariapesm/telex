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

      user = lookup_user(key: api_key)

      unless user
        raise Pliny::Errors::Unauthorized
      end

      Pliny::RequestStore.store[:current_user] = user
      @app.call(env)
    end

    private

    def lookup_user(key:)
      return nil unless key =~ Pliny::Middleware::RequestID::UUID_PATTERN

      cache_find(key: key) || api_find(key: key)
    end

    def api_find(key:)
      client = Telex::HerokuClient.new(api_key: key)
      user_response = client.account_info

      user = find_or_create_user(
        heroku_id: user_response.fetch('id'),
        email:     user_response.fetch('email')
      )

      cache_store(user_id: user.id, key: key)

      user
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

    def cache_find(key:)
      return unless Config.cache_user_auth?
      id = nil
      Sidekiq.redis {|c| id = c.get("keycache.#{hmac(key)}") }
      User[id: id]
    end

    def cache_store(user_id:, key:)
      return unless Config.cache_user_auth?
      Sidekiq.redis {|c| c.setex("keycache.#{hmac(key)}", 3600, user_id) }
    end

    def hmac(raw_key)
      OpenSSL::HMAC.hexdigest("sha512", Config.api_key_hmac_secret, raw_key)
    end
  end
end
