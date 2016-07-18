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

  it "can regenerate a new token when `title` `body` is supplied" do
    recipient = Fabricate(:recipient)
    old_token = recipient.verification_token

    allow(Mediators::Recipients::Emailer).to receive(:run).with(
      app_info: app_info, recipient: recipient, title: "hello", body: "{{app}} {{token}}"
    )

    described_class.run(app_info: app_info, recipient: recipient, title: "hello", body: "{{app}} {{token}}")
    expect(recipient.verification_token).to_not eq(old_token)
  end

  it "can does not regenerate a new token when `refresh_token: false` is supplied" do
    recipient = Fabricate(:recipient)
    old_token = recipient.verification_token

    allow(Mediators::Recipients::Emailer).to receive(:run).with(app_info: app_info, recipient: recipient)

    described_class.run(app_info: app_info, recipient: recipient)
    expect(recipient.verification_token).to eq(old_token)
  end
end
