module Mediators::Messages
  class Plexer < Mediators::Base
    attr_reader :user_ids

    def initialize(message:, user_finder: nil)
      @message = message
      @user_finder = user_finder
      @user_ids = []
    end

    def call
      get_users
    end

    def get_users
      @user_ids = user_finder.call(@message)
    end

    private

    def user_finder
      @user_finder ||= begin

                       end
    end
  end
end
