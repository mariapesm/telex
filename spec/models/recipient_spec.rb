require "spec_helper"

describe Recipient do
  it 'prevents dups of app_id, email combinations' do
    app_id = SecureRandom.uuid
    email = "%s@example.com" % app_id
    Fabricate(:recipient, app_id: app_id, email: email)

    expect {
      Fabricate(:recipient, app_id: app_id, email: email)
    }.to raise_error(Sequel::UniqueConstraintViolation)
  end

  describe 'token validation' do
    let :recipient do
      Fabricate(:recipient)
    end

    it 'it validates correctly' do
      expect(recipient.valid_token?(recipient.verification_token)).to eq(true)
    end

    it 'it validates the TTL' do
      recipient.update(verification_sent_at: Time.now.utc - Recipient::VERIFICATION_TOKEN_TTL * 2)
      expect(recipient.valid_token?(recipient.verification_token)).to eq(false)
    end

    it 'it rejects bad tokens' do
      expect(recipient.valid_token?("whatever")).to eq(false)
    end
  end

  describe "find active by app id" do
    let :recipient do
      Fabricate(:recipient)
    end

    let :under_test do
      Recipient.find_active_by_app_id(app_id: recipient.app_id)
    end

    it "should return all active, verified, none-deleted, by app" do
      recipient.update(verified: true, active: true, deleted_at: nil)

      expect(under_test.first.id).to eql(recipient.id)
    end

    it "should reject non-verified" do
      recipient.update(verified: false, active: true)

      expect(under_test.count).to eql(0)
    end

    it "should reject non-active" do
      recipient.update(verified: true, active: false)

      expect(under_test.count).to eql(0)
    end

    it "shoud reject deleted" do
      recipient.update(verified: true, active: true, deleted_at: Time.now)

      expect(under_test.count).to eql(0)
    end
  end
end
