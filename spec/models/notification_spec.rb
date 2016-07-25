require 'spec_helper'

describe Notification do
  let :message do
    Message.create(
      target_type: 'app', target_id: SecureRandom.uuid,
      title: 'hello', body: 'world',
      producer: Producer.create(api_key: SecureRandom.uuid, name: 'myservice')
    )
  end

  let :user do
    User.create(heroku_id: SecureRandom.uuid, email: 'foo@bar.com')
  end

  let :recipient do
    Fabricate(:recipient)
  end

  it 'has a notifiable from user if non-nil' do
    n = Notification.create(user: user, message: message)
    expect(n.notifiable).to eq(user)
  end

  it 'has a notifiable from recipient if non-nil' do
    n = Notification.create(recipient: recipient, message: message)
    expect(n.notifiable).to eq(recipient)
  end

  it 'validates uniqueness of (user,message)' do
    Notification.create(user: user, message: message)
    expect {
      Notification.create(user: user, message: message)
    }.to raise_error(Sequel::ValidationFailed)
  end

  it 'validates uniqueness of (recipient,message)' do
    Notification.create(recipient: recipient, message: message)
    expect {
      Notification.create(recipient: recipient, message: message)
    }.to raise_error(Sequel::ValidationFailed)
  end
end
