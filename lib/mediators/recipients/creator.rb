module Mediators::Recipients
  class Creator < Mediators::Base
    attr_reader :app_info, :email, :active

    def initialize(app_info:, email: nil, active: false)
      @app_info = app_info
      @email = email
      @active = active
    end

    def call
      recipient = Recipient.create(
        email: email,
        app_id: app_info.fetch("id"),
        verification_token: Recipient.generate_token
      )
      Emailer.run(app_info: app_info, recipient: recipient)
      recipient
    end
  end
end
