require "spec_helper"

describe Mediators::Recipients::Deleter do
  it "deletes" do
    set = Recipient.where(deleted_at: nil)
    recipient = Fabricate(:recipient)
    expect { described_class.run(recipient: recipient) }.to change(set, :count).by(-1)
  end
end
