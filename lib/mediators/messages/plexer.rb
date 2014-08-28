module Mediators::Messages
  class Plexer < Mediators::Base
    attr_reader :users
    attr_writer :user_finder

    def initialize(message:)
      @message = message
      @users = []
    end

    def call
      get_users
      create_notifications
    end

    private

    def get_users
      @users = user_finder.call(@message)
    end

    def create_notifications
      users.each do |user|
        Mediators::Notifications::Creator.run(message: @message, user: user)
      end
    end

    def user_finder
      @user_finder
    end
  end
end
