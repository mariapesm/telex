module Mediators::Notifications
  class ReadStatusUpdater < Mediators::Base
    def initialize(notification:, read_status:, read_time: Time.now)
      @notification = notification
      @read_at = read_status ? read_time : nil
    end

    def call
      @notification.update(read_at: @read_at)
      @notification
    end
  end
end
