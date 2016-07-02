require "spec_helper"

describe Mediators::Recipients::Creator do
  before do
    producer = Fabricate(:producer)
    @app_info = {
      "id" => SecureRandom.uuid,
      "name" => "brat",
    }
    @creator = described_class.new(app_info: @app_info,
                                   email: "foo@bar.com",
                                   callback_url: "http://x.com/%{token}")
  end

  it "creates a recipient" do
    emailer = double()
    args = {
      email: "foo@bar.com",
      notification_id: Pliny::Middleware::RequestID::UUID_PATTERN,
      subject: described_class::TITLE,
      body: %r(http://x.com/[a-z0-9\-]+),
    }
    allow(Telex::Emailer).to receive(:new).with(hash_including(args)) { emailer }
    allow(emailer).to receive(:deliver!)

    result = nil
    expect{ result = @creator.call }.to change(Recipient, :count).by(1)
    expect(result).to be_instance_of(Recipient)
  end
end
