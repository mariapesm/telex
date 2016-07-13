module Mediators::Recipients
  class Creator < Mediators::Base
    attr_reader :app_info, :email, :callback_url, :active

    def initialize(app_info:, email: nil, callback_url:, active: false)
      @app_info = app_info
      @email = email
      @active = active
      @callback_url = callback_url
    end

    def call
      recipient = Recipient.create(
        email: email,
        app_id: app_info.fetch("id"),
        callback_url: callback_url,
        verification_token: Recipient.generate_token
      )
      Emailer.run(app_info: app_info, recipient: recipient)
      recipient
    end
  end
end
