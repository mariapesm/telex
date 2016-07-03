require "spec_helper"

describe Mediators::Recipients::Verifier do
  let(:app_info) {{ "name" => "myapp" }}

  it "verifies and makes active" do
    recipient = Fabricate(:recipient, active: false, verified: false)

    described_class.run(recipient: recipient)
    expect(recipient.active).to eq(true)
    expect(recipient.verified).to eq(true)
  end
end
