require "spec_helper"

describe Recipient do
  it 'validates callback_url format, id, token presence' do
    cases = [
      ["http://localhost/%{token}", true],
      ["http://localhost/%{id}/", false],
      ["http://localhost/%{token1}", false],
      ["yolo", false],
      ["www.yolo", false],
      ["www.yolo.com/%{token}", false],
    ]

    cases.each do |url, ok|
      r = Recipient.new(
        callback_url: url,
        app_id: SecureRandom.uuid,
        email: "foo@bar.com",
      )
      expect(r.valid?).to eq(ok)
    end
  end  

  it 'prevents dups of app_id, email combinations' do
    app_id = SecureRandom.uuid
    email = "%s@example.com" % app_id
    Recipient.create(email: email, app_id: app_id, callback_url: "http://x.com/%{token}")

    expect {
      Recipient.create(email: email, app_id: app_id, callback_url: "http://x.com/%{token}")
    }.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it 'is able to find via verification token' do
    app_id = SecureRandom.uuid
    email = "%s@example.com" % app_id
    r = Recipient.create(email: email, app_id: app_id, callback_url: "http://x.com/%{token}")
    
    actual = Recipient.find_by_app_id_and_verification_token(app_id: app_id, verification_token: r.verification_token)
    expect(actual).to eq(r)
  end
end
