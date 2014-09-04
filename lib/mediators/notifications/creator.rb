module Mediators::Notifications
  class Creator < Mediators::Base
    def initialize(user:, message:)
      @user = user
      @message = message
    end

    def call
      Notification.create(user_id: @user.id, message_id: @message.id)
    end
  end
end

