require "spec_helper"

describe Mediators::Notifications::ReadStatusUpdater, '#call' do
  let(:mediator) { described_class.new(notification: @notification, read_status: @status, read_time: @time) }

  before do
    @time = Time.now
    @status = true
    @notification = instance_double(Notification, update: nil)
  end

  it 'returns the notification' do
    result = mediator.call
    expect(result).to_not be_nil
    expect(result).to eq(@notification)
  end

  it 'with a true status, sets read_at to now' do
    @status = true
    mediator.call
    expect(@notification).to have_received(:update).with(read_at: @time)
  end

  it 'with a false status, sets read_at to nil' do
    @status = false
    mediator.call
    expect(@notification).to have_received(:update).with(read_at: nil)
  end
end
