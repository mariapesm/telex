module Mediators::Recipients
  class Updater < Mediators::Base
    attr_reader :app_info, :recipient, :active, :refresh_token

    def initialize(app_info:, recipient:, refresh_token: false, active: false)
      @app_info = app_info
      @recipient = recipient
      @refresh_token = refresh_token
      @active = active      
    end

    def call
      recipient.active = active
      recipient.set(maybe_regenerate_token(refresh_token: refresh_token))
      recipient.save

      if refresh_token
        Emailer.run(app_info: app_info, recipient: recipient)
      end

      recipient
    end

    def maybe_regenerate_token(refresh_token:)
      return {} unless refresh_token

      { verification_token: Recipient.generate_token, verification_sent_at: Time.now.utc }
    end
  end
end
