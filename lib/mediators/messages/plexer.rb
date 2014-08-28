module Mediators::Messages
  class Plexer < Mediators::Base
    attr_accessor :user_finder, :message, :users
    private :users=, :message=

    def initialize(message:)
      self.message = message
      self.users = []
      self.user_finder = Mediators::Messages::UserFinder.from_message(message)
    end

    def call
      get_users
      create_notifications
    end

    private

    def get_users
      self.users = user_finder.call(message)
    end

    def create_notifications
      users.each do |user|
        Mediators::Notifications::Creator.run(message: message, user: user)
      end
    end
  end
end
