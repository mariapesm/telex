module Mediators::Notifications
  class Creator < Mediators::Base
    def initialize(user:, message:)
      self.user = user
      self.message = message
    end

    def call
      self.notification = Notification.create(user_id: user.id, message_id: message.id)
      send_email
      notification
    end

    private
    attr_accessor :user, :message, :notification

    def send_email
      emailer = Telex::Emailer.new(
        email: user.email,
        notification_id: notification.id,
        subject: message.title,
        body: message.body,
      )
      emailer.deliver!
    end

  end
end

