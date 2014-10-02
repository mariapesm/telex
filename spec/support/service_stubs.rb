class HerokuApiStub < Sinatra::Base
  OWNER_ID   = SecureRandom.uuid
  COLLAB1_ID = SecureRandom.uuid
  COLLAB2_ID = SecureRandom.uuid

  helpers do
    def check_version!
      if env["HTTP_ACCEPT"] != "application/vnd.heroku+json; version=3"
        halt 406
      end
    end

    def authenticate!
      auth_url = URI.parse(Config.heroku_api_url)
      if auth_credentials != [auth_url.user, auth_url.password]
        halt 401
      end
    end

    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end
  end

  before do
    check_version!
    authenticate!
  end

  get "/account" do
    MultiJson.encode(
      id:    env["HTTP_USER"],
      email: "username@example.com")
  end

  get "/apps/:id" do |id|
    MultiJson.encode(
      name: "example",
      owner: {
        id:    OWNER_ID,
        email: "username@example.com",
      })
  end

  get "/apps/:id/collaborators" do
    MultiJson.encode([
      {
        id: SecureRandom.uuid,
        user: {
          id:    COLLAB1_ID,
          email: "username2@example.com"
        }
      },
      {
        id: SecureRandom.uuid,
        user: {
          id:    COLLAB2_ID,
          email: "username3@example.com"
        }
      },
    ])
  end
end

def stub_heroku_api
  WebMock.stub_request(:any, %r{#{Config.heroku_api_url}/.*}).
    to_rack(HerokuApiStub)
end
