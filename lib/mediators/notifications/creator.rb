module Mediators::Notifications
  class Creator < Mediators::Base
    def initialize(user:, message:)
      self.user    = user
      self.message = message
    end

    def call
      self.notification = Notification.create(user_id: user.id, message_id: message.id)
      # One possibility. Just jotting down notes
      # send_email unless message.target_type == Message::DASHBOARD
      send_email
      notification
    rescue Sequel::ValidationFailed, Sequel::UniqueConstraintViolation
      # Notification already queued, just ignore.
      Pliny.log(duplicate_notificaiton: true, user_id: user.id, message_id: message.id)
    rescue => e
      # ^ Typically an email send failure.
      # Remove the notification before we re-raise so the mediator can be run
      # again.
      Notification.where(user_id: user.id, message_id: message.id).delete
      raise e
    end

    private
    attr_accessor :user, :message, :notification

    def send_email
      emailer = Telex::Emailer.new(
        email: user.email,
        notification_id: notification.id,
        subject: message.title,
        body: message.body,
        action: message.action,
      )
      emailer.deliver!
    end

  end
end

