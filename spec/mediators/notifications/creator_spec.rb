require "spec_helper"

describe Mediators::Notifications::Creator do
  before do
    @creator = described_class.new(user: Fabricate(:user), message: Fabricate(:message))
  end

  it 'creates a message' do
    result = nil
    expect{ result = @creator.call }.to change(Notification, :count).by(1)
    expect(result).to be_instance_of(Notification)
  end
end
