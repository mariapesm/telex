require "spec_helper"

describe Endpoints::Producer::Messages do
  include Rack::Test::Methods

  def app
    Routes
  end

  HerokuMockUser = Struct.new(:heroku_id, :email)
  def create_heroku_user
    HerokuMockUser.new(SecureRandom.uuid, Faker::Internet.email)
  end

  HerokuMockApp = Struct.new(:id)
  def create_heroku_app(owner:, collaborators:[])
    url_root = "https://telex:#{Config.heroku_api_key}@api.heroku.com"

    app = HerokuMockApp.new(SecureRandom.uuid)
    app_response = {
      "name" => "example",
        "owner" => {
          "email" => owner.email,
          "id" => owner.heroku_id
         }
    }
    stub_request(:get, "#{url_root}/apps/#{app.id}")
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
    stub_request(:get, "#{url_root}/apps/#{app.id}/collaborators")
      .to_return( body: MultiJson.encode(collab_response) )

    app
  end


  before do
    header "Content-Type", "application/json"

    producer = Fabricate(:producer, api_key: 'foo')
    authorize producer.id, 'foo'

    @h_user1 = create_heroku_user
    Fabricate(:user, email: "outdated@email.com", heroku_id: @h_user1.heroku_id)
    @h_user2 = create_heroku_user
    heroku_app = create_heroku_app(owner: @h_user1, collaborators:[@h_user1, @h_user2])

    @message_body = {
      title: Faker::Company.bs,
      body: Faker::Company.bs,
      target: {type: 'app', id: heroku_app.id}
    }
  end

  def do_post
    post '/producer/messages', MultiJson.encode(@message_body)
  end

  it 'works' do
    # sanity checks
    expect(User.count).to eq(1)
    existing_user = User.first
    expect(existing_user.email).to eq("outdated@email.com")
    expect(@h_user1.email).to_not eq("outdated@email.com")
    expect(existing_user.heroku_id).to eq(@h_user1.heroku_id)

    # action
    Sidekiq::Testing.inline! do
      do_post
      existing_user.reload
    end

    # verification
    expect(last_response.status).to eq(201)
    expect(User.count).to eq(2)
    expect(existing_user.email).to eq(@h_user1.email)

    notifications = Notification.all
    users = User.all
    expect(notifications.count).to eq(2)
    expect(notifications.map(&:user_id)).to match(users.map(&:id))
  end
end
