require 'webmock'
module HerokuAPIMock
  include WebMock::API
  extend self

  HerokuMockUser = Struct.new(:heroku_id, :email)
  def create_heroku_user
    user = HerokuMockUser.new(SecureRandom.uuid, Faker::Internet.email)

    user_response = {
      "email" => user.email,
      "id" => user.heroku_id
    }
    stub_request(:get, "#{Config.heroku_api_url}/account")
      .with(headers: {"User" => user.heroku_id})
      .to_return(body: MultiJson.encode(user_response))

    return user
  end

  HerokuMockApp = Struct.new(:id)
  def create_heroku_app(owner:, collaborators:[])
    app = HerokuMockApp.new(SecureRandom.uuid)
    app_response = {
      "name" => "example",
        "owner" => {
          "email" => owner.email,
          "id" => owner.heroku_id
         }
    }
    stub_request(:get, "#{Config.heroku_api_url}/apps/#{app.id}")
      .to_return(body: MultiJson.encode(app_response))

     collab_response = collaborators.map do |user|
       {
         "created_at" => "2012-01-01T12:00:00Z",
         "id" => SecureRandom.uuid,
         "updated_at" => "2012-01-01T12:00:00Z",
         "user" => {
           "email" => user.email,
           "id" => user.heroku_id,
           "two_factor_authentication" => false
         }
       }
    end
    stub_request(:get, "#{Config.heroku_api_url}/apps/#{app.id}/collaborators")
      .to_return( body: MultiJson.encode(collab_response) )

    return app
  end
end
