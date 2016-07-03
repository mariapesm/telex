require "spec_helper"

describe Mediators::Recipients::Updater do
  let(:app_info) {{ "name" => "myapp" }}

  it "can change from active to inactive" do
    recipient = Fabricate(:recipient)

    described_class.run(app_info: app_info, recipient: recipient, active: true)
    expect(recipient.active).to eq(true)

    described_class.run(app_info: app_info, recipient: recipient, active: false)
    expect(recipient.active).to eq(false)
  end

  it "can regenerate a new token when callback_url is supplied" do
    recipient = Fabricate(:recipient)
    old_token = recipient.verification_token

    allow(Mediators::Recipients::Emailer).to receive(:run).with(app_info: app_info, recipient: recipient)

    described_class.run(app_info: app_info, recipient: recipient, callback_url: "http://x.com/%{token}")
    expect(recipient.verification_token).to_not eq(old_token)
  end
end
