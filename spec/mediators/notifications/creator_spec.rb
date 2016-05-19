require "spec_helper"

describe Mediators::Notifications::Creator do
  before do
    @creator = described_class.new(user: Fabricate(:user), message: Fabricate(:message))
  end

  it 'creates a message' do
    result = nil
    expect{ result = @creator.call }.to change(Notification, :count).by(1)
    expect(result).to be_instance_of(Notification)
    expect(Mail::TestMailer.deliveries.count).to be(1)
  end

  it 'does not send duplicate messages' do
    expect do
      @creator.call
      @creator.call
    end.to change(Notification, :count).by(1)

    expect(Mail::TestMailer.deliveries.count).to be(1)
  end

  it 'removes the Notification object on message send failures' do
    allow(Telex::Emailer).to receive(:new) { raise Net::ReadTimeout }
    expect{ @creator.call }.to raise_error Net::ReadTimeout
    expect(Mail::TestMailer.deliveries.count).to be(0)
    expect(Notification.count).to be(0)
  end
end
