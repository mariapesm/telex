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
end
