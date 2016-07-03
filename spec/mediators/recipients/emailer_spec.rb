require "spec_helper"

describe Mediators::Recipients::Emailer do
  let(:app_info) {{ "name" => "myapp" }}
  let(:recipient) { Fabricate(:recipient, callback_url: "http://x.com/%{token}") }

  it "sends an email given recipient / app_info" do
    emailer = double()
    args = {
      email: recipient.email,
      notification_id: Pliny::Middleware::RequestID::UUID_PATTERN,
      subject: described_class::TITLE,
      body: %r(http://x.com/[a-z0-9\-]+),
    }
    allow(Telex::Emailer).to receive(:new).with(hash_including(args)) { emailer }
    allow(emailer).to receive(:deliver!)

    described_class.run(app_info: app_info, recipient: recipient)
  end
end
