module Mediators::Messages
  class Plexer < Mediators::Base
    attr_accessor :user_finder, :message, :users_with_role
    private :users_with_role=, :message=

    def initialize(message:)
      self.message = message
      self.users_with_role = []
      self.user_finder = Mediators::Messages::UserFinder.from_message(message)
    end

    def call
      get_users
      create_notifications
    end

    private

    def get_users
      self.users_with_role = user_finder.call
    end

    def create_notifications
      users_with_role.map(&:user).uniq { |u| u.id }.each do |user|
        Mediators::Notifications::Creator.run(message: message, notifiable: user)
      end
    end
  end
end
