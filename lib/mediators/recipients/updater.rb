module Mediators::Recipients
  class Updater < Mediators::Base
    attr_reader :app_info, :recipient, :active, :title, :body

    def initialize(app_info:, recipient:, active: false, title: "", body: "")
      @app_info = app_info
      @recipient = recipient
      @title = title.to_s
      @body = body.to_s
      @active = active      
    end

    def call
      recipient.active = active
      recipient.set(maybe_regenerate_token(title: title, body: body))
      recipient.save

      if regenerate_token?
        Emailer.run(app_info: app_info, recipient: recipient, title: title, body: body)
      end

      recipient
    end

    def maybe_regenerate_token(title:, body:)
      return {} unless regenerate_token? 

      { verification_token: Recipient.generate_token, verification_sent_at: Time.now.utc }
    end

    def regenerate_token?
      !title.empty? && !body.empty?
    end
  end
end
