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
      attributes = maybe_regenerate_token(active: active, refresh_token: refresh_token)
      recipient.update(attributes)

      if attributes[:verification_token]
        Emailer.run(app_info: app_info, recipient: recipient)
      end

      recipient
    end

    def maybe_regenerate_token(attributes)
      if attributes.delete(:refresh_token)
        attributes[:verification_token] = Recipient.generate_token
        attributes[:verification_sent_at] = Time.now.utc
      end
      attributes
    end
  end
end
