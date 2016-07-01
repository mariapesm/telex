module Mediators::Recipients
  class Creator < Base
    TITLE = "Heroku Email Verification"
    ACTION_LABEL = "Confirm Email"

    def call
      authorize!
      recipient = Recipient.create(email: email, app_id: app_id, callback_url: callback_url)
      send_email(recipient: recipient, notification_id: recipient.id)
      recipient
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
