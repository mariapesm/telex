require "spec_helper"

describe Mediators::Recipients::Creator do
  before do
    producer = Fabricate(:producer)
    @app_id = SecureRandom.uuid
    @creator = described_class.new(app_id: @app_id,
                                   email: "foo@bar.com",
                                   callback_url: "http://x.com/%{id}/%{token}",
                                   heroku_client: Telex::HerokuClient.new)
  end

  it "creates a recipient" do
    stub_request(:get, "https://telex:a_very_secret_api_key@api.heroku.com/apps/#{@app_id}").
                 with(:headers => {
                   "Accept"=>"application/vnd.heroku+json; version=3",
                   "Authorization"=>"Basic dGVsZXg6YV92ZXJ5X3NlY3JldF9hcGlfa2V5",
                   "Host"=>"api.heroku.com:443",
                   "Range"=>"id ..; max=1000;", "User-Agent"=>"telex"
                 }).
                 to_return(:status => 200, :body => '{"name": "brat"}', :headers => {})

    emailer = double()
    args = {
      email: "foo@bar.com",
      notification_id: Pliny::Middleware::RequestID::UUID_PATTERN,
      subject: described_class::TITLE,
      body: %r(http://x.com/[a-z0-9\-]+/[a-z0-9\-]+),
    }
    allow(Telex::Emailer).to receive(:new).with(hash_including(args)) { emailer }
    allow(emailer).to receive(:deliver!)

    result = nil
    expect{ result = @creator.call }.to change(Recipient, :count).by(1)
    expect(result).to be_instance_of(Recipient)
  end
end
