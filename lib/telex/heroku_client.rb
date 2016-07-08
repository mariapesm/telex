require 'uri'
module Telex
  class HerokuClient

    class NotFound < StandardError ; end

    attr_accessor :uri
    private :uri=

    def initialize(api_key: nil)
      self.uri = URI.parse(Config.heroku_api_url)
      if api_key
        uri.password = api_key
      end
    end

    def account_info(user_uuid: nil)
      if user_uuid
        get("/account", user: user_uuid)
      else
        get("/account", base_headers_only: true)
      end
    end

    def app_info(app_uuid, base_headers_only: false)
      get("/apps/#{app_uuid}", base_headers_only: base_headers_only)
    end

    def app_collaborators(app_uuid)
      get("/apps/#{app_uuid}/collaborators")
    end

    def organization_members(organization_name)
      get("/organizations/#{organization_name}/members")
    end

    private

    def client
      @client ||= Excon.new(uri.to_s)
    end

    def headers(base_headers_only: false, user: nil, range: nil)
      range = "id ..; max=1000;" if range.nil?

      base = {
        "Accept"     => "application/vnd.heroku+json; version=3",
        "User-Agent" => "telex",
        "Range"      => range
      }

      if base_headers_only
        base
      else
        base.merge(additional_headers(user: user))
      end
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
        expects: [200, 206],
        headers: headers(options),
        path:    path)
      content = MultiJson.decode(response.body)

      if more_data? response
        opts = {range: response.headers['Next-Range'] }.merge(options)
        content.concat get(path, opts)
      end

      content
    rescue Excon::Errors::NotFound
      raise Telex::HerokuClient::NotFound
    end

    def more_data?(response)
      response.status == 206 && response.headers.key?('Next-Range')
    end
  end
end
