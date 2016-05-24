unless Config.rack_env == 'test'
  Rollbar.configure do |config|
    config.enabled = (Config.rack_env == 'production')
    config.environment = Config.console_banner || 'production'
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
    config.use_sucker_punch
    config.disable_monkey_patch = true
    config.root = Config.root

    config.scrub_headers |= %w[
      Authorization
      Cookie
      Set-Cookie
      X-Csrf-Token
    ]

    config.scrub_fields |= %i[
      access_token
      api_key
      authenticity_token
      bouncer.refresh_token
      bouncer.token
      confirm_password
      heroku_oauth_token
      heroku_session_nonce
      heroku_user_session
      oauth_token
      passwd
      password
      password_confirmation
      postgres_session_nonce
      request.cookies.signup-sso-session
      secret
      secret_token
      sudo_oauth_token
      super_user_session_secret
      user_session_secret
      www-sso-session
    ]

    config.exception_level_filters.merge!(
      'Telex::Emailer::DeliveryError' => 'warning'
    )
  end

  require 'rollbar/sidekiq'
end
