module Telex
  module HerokuClient
    extend self

    def account_info(user_uuid)

    end

    def app_info(app_uuid)
      get("/apps/#{app_uuid}")
    end

    def app_collaborators(app_uuid)
      get("/apps/#{app_uuid}/collaborators")
    end

    private

    def client
      Excon.new(Config.heroku_api_url)
    end

    def get(path)
      headers = {"Accept"=>"application/vnd.heroku+json; version=3"}
      if Config.obscurity_api_header
        headers.merge!( {Config.obscurity_api_header => true} )
      end
      result = client.get(expects: 200, path: path, headers: headers)
      MultiJson.decode(result.body)
    end
  end
end
