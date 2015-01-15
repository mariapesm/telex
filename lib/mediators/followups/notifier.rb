module Mediators::Followups
  class Notifier < Mediators::Base
    attr_accessor :followup, :message, :notifications
    def initialize(followup: )
      self.followup = followup
      self.message = followup.message
      self.notifications = message.notifications
    end

    def call
      update_users
      notify_users
    end

    private

    def update_users
      notifications.each do |note|
        user = note.user
        Mediators::Messages::UserUserFinder.run(target_id: user.heroku_id)
      end
    end

    def notify_users
      notifications.each do |note|
        user = note.user
        emailer = Telex::Emailer.new(
          email: user.email,
          in_reply_to: note.id,
          subject: message.title,
          body: followup.body
        )
        emailer.deliver!
      end
    end
  end
end
