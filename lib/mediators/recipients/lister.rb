module Mediators::Recipients
  class Lister < Mediators::Base
    attr_reader :app_info

    def initialize(app_info:)
      @app_info = app_info      
    end

    def call
      Recipient.where(app_info: app_info.fetch("id"))
    end
  end
end
