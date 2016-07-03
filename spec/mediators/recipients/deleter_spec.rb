require "spec_helper"

describe Mediators::Recipients::Deleter do
  it "deletes" do
    recipient = Fabricate(:recipient)
    expect { described_class.run(recipient: recipient) }.to change(Recipient, :count).by(-1)
  end
end
