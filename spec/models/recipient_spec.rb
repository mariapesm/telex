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

  it 'is able to find via verification token' do
    app_id = SecureRandom.uuid
    email = "%s@example.com" % app_id
    r = Fabricate(:recipient, email: email, app_id: app_id)
    
    actual = Recipient.verify(app_id: app_id, id: r.id, verification_token: r.verification_token)
    expect(actual).to eq(r)
  end
end
