module Mediators::Followups
  class Notifier < Mediators::Base
    attr_accessor :followup, :message, :users
    def initialize(followup: followup)
      self.followup = followup
      self.message = followup.message
      self.users = message.users
    end

    def call
      update_users
      notify_users
    end

    private

    def update_users
      users.each do |user|
        Mediators::Messages::UserUserFinder.run(target_id: user.heroku_id)
      end
    end

    def notify_users
      users.each do |user|
        emailer = Telex::Emailer.new(
          email: user.email,
          in_reply_to: message.id,
          subject: message.title,
          body: followup.body
        )
        emailer.deliver!
      end
    end
  end
end
