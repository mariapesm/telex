require 'uri'
module Telex
  class HerokuClient
    def initialize
      @uri = URI.parse(Config.heroku_api_url)
    end

    def account_info(user_uuid=nil)
      get("/account", user: user_uuid)
    end

    def app_info(app_uuid)
      get("/apps/#{app_uuid}")
    end

    def app_collaborators(app_uuid)
      get("/apps/#{app_uuid}/collaborators")
    end

    private

    def client
      @client ||= Excon.new(@uri.to_s)
    end

    def headers(options)
      base = { "Accept" => "application/vnd.heroku+json; version=3" }
      base.merge(additional_headers(options))
    end

    def additional_headers(user: nil)
      return {} unless Config.additional_api_headers
      template = MultiJson.decode(Config.additional_api_headers)
      if user
        Hash[template.map {|(k,v)| [k,v.sub('{{user}}', user)] }]
      else
        template.reject {|k,v| v == '{{user}}'}
      end
    end

    def get(path, options={})
      response = client.get(
        expects: 200,
        headers: headers(options),
        path:    path)
      MultiJson.decode(response.body)
    end
  end
end
