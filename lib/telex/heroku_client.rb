module Telex
  module HerokuClient
    extend self

    def account_info(user_uuid)
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
      @client ||= Excon.new(Config.heroku_api_url)
    end

    def headers(options)
      base = { "Accept" => "application/vnd.heroku+json; version=3" }
      base.merge(additional_headers(options))
    end

    def additional_headers(options)
      return {} unless Config.additional_api_headers
      Config.additional_api_headers.split("\n").inject({}) do |headers, raw|
        name, value = raw.split(": ")
        if options[:user]
          value.sub!("{{user}}", options[:user])
        end
        headers.merge!(name => value)
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
