module Mediators::Messages
  class AppInfoFetcher < Mediators::Base
    attr_accessor :target_id

    AppInfo = Struct.new(:name)

    def initialize(target_id:)
      self.target_id = target_id
    end

    def call
      get_app_info
    end

    private

    def heroku_client
      Telex::HerokuClient.new
    end

    def get_app_info
      app_response  = heroku_client.app_info(target_id)
      AppInfo.new(app_response.fetch("name"))
    end
  end
end
