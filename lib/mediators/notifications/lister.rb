module Mediators::Notifications
  class Lister < Mediators::Base
    def initialize(user:)
      @user = user
    end

    def call
     Notification
      .eager_graph(:message=>:followup)
      .where(user: @user)
      .order(Sequel.desc(:created_at))
      .all
    end
  end
end
