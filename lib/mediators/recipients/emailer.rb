module Mediators::Recipients
  class Emailer < Mediators::Base
    TITLE = "Your Heroku Confirmation Code: Email Notifications"

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
          token: recipient.verification_token,
          app: app_info.fetch("name")
        },
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
      We've received your request to add an email address to your app — %{app} — for Threshold Alerting.

      Go to your Application Metrics, select Configure Alerts > Add Email for Alert Notifications, and enter this code: %{token}

      If you require further assistance, please [open a ticket](https://help.heroku.com/) with Heroku Support.
    EOT
  end
end
