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
      mail = Mail.new
      mail.to         = user.email
      mail.from       = 'Heroku <bot@heroku.com>'
      mail.message_id = "<#{message.id}@notifications.heroku.com>"
      mail.subject    = message.title
      mail.body       = message.body

      mail.deliver!
    end
  end
end

