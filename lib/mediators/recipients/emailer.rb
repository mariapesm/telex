module Mediators::Recipients
  class Emailer < Mediators::Base
    TITLE = "Heroku Email Verification"
    ACTION_LABEL = "Confirm Email"

    attr_reader :app_info, :recipient

    def initialize(app_info:, recipient:)
      @app_info = app_info
      @recipient = recipient 
    end

    def call
      send_email(recipient: recipient, notification_id: recipient.id)
    end

  private
    def generate_confirmation_for(recipient)
      Message.new(
        title: TITLE,
        body: CONFIRMATION_TEMPLATE % {
          url: recipient.verification_url,
          app: app_info.fetch("name")
        },
        action_url: recipient.verification_url,
        action_label: ACTION_LABEL
      )
    end

    def send_email(recipient:, notification_id:)
      message = generate_confirmation_for(recipient)
      emailer = Telex::Emailer.new(
        email: recipient.email,
        notification_id: notification_id,
        subject: message.title,
        body: message.body,
        action: message.action,
      )
      emailer.deliver!
    end

    CONFIRMATION_TEMPLATE = (<<-EOT).gsub(/^ {6}/, "")
      Hello,

      We've received your request to add an email to %{app} for Threshold Alerting.

      To confirm the setup click on the following link:

          %{url}

      - Heroku Alerting Engine
    EOT
  end
end
