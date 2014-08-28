module Mediators::Messages
  class UserFinder < Mediators::Base
    attr_accessor :message

    def self.from_message(message)
      AppUserFinder.new(message: message)
    end

    def initialize(message: message)
      self.message = message
    end


    def call

    end
  end

  class UserUserFinder < UserFinder

  end

  class AppUserFinder < UserFinder

  end
end
