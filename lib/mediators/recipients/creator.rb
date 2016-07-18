module Mediators::Recipients
  class Creator < Mediators::Base
    attr_reader :app_info, :email, :title, :body

    def initialize(app_info:, email:, title:, body:)
      @app_info = app_info
      @email = email
      @title = title
      @body = body
    end

    def call
      recipient = Recipient.create(
        email: email,
        app_id: app_info.fetch("id"),
        verification_token: Recipient.generate_token
      )
      Emailer.run(app_info: app_info, recipient: recipient, title: title, body: body)
      recipient
    end
  end
end
