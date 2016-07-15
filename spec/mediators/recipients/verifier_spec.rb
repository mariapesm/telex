require "spec_helper"

describe Mediators::Recipients::Verifier do
  let(:app_info) {{ "name" => "myapp" }}

  it "verifies and makes active" do
    recipient = Fabricate(:recipient, active: false, verified: false)

    described_class.run(recipient: recipient, token: recipient.verification_token)
    expect(recipient.active).to eq(true)
    expect(recipient.verified).to eq(true)
  end

  it "throws NotFound on bad token" do
    recipient = Fabricate(:recipient, active: false, verified: false)

    expect { described_class.run(recipient: recipient, token: "whatever") }.
      to raise_error(Mediators::Recipients::NotFound)
  end
end
