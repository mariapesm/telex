module Mediators::Recipients
  class Creator < Mediators::Base
    attr_reader :app_info, :email, :title, :body

    def initialize(app_info:, email:, template: nil, title: nil, body: nil)
      @app_info = app_info
      @email = email

      if template.to_s.empty?
        @title = title
        @body = body
      else
        @title, @body = TemplateFinder.run(template: template)
      end
    end

    def call
      Limiter.run(app_info: app_info)

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
