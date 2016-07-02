module Mediators::Recipients
  class Updater < Mediators::Base
    attr_reader :app_info, :recipient, :active, :callback_url

    def initialize(app_info:, recipient:, callback_url: nil, active: false)
      @app_info = app_info
      @recipient = recipient
      @callback_url = callback_url
      @active = active      
    end

    def call
      attributes = maybe_regenerate_token(active: active, callback_url: callback_url)
      recipient.update(attributes)

      if attributes[:verification_token]
        Emailer.run(app_info: app_info, recipient: recipient)
      end

      recipient
    end

    def maybe_regenerate_token(attributes)
      if attributes[:callback_url].to_s.empty?
        attributes.delete(:callback_url)
      else
        attributes[:verification_token] = SecureRandom.uuid
        attributes[:verification_sent_at] = Time.now.utc
      end
      attributes
    end
  end
end
