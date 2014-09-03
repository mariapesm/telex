require "spec_helper"

include Mediators::Messages

describe Plexer, '#call' do
  before do
    @message = instance_double(Message, target_type: 'app', target_id: SecureRandom.uuid)
    @plexer = Plexer.new(message: @message)
    @uwrs = Array.new(2) { UserWithRole.new(role: :whatever, user: instance_double(User)) }
  end

  it 'uses the user finder to set @users_with_role' do
    user_finder = double('user finder')
    @plexer.user_finder = user_finder

    expect(@plexer.users_with_role).to eq([])
    expect(user_finder).to receive(:call).and_return( @uwrs )
    @plexer.call
    expect(@plexer.users_with_role).to eq(@uwrs)
  end

  it 'picks the appropriate user finder' do
    allow(@message).to receive(:target_type).and_return('app')
    plexer = Plexer.new(message: @message)
    expect(plexer.user_finder).to be_instance_of(Mediators::Messages::AppUserFinder)
  end

  it 'creates a Notificaton for each user' do
    @plexer.user_finder = double('user finder', call: @uwrs)

    expect(Mediators::Notifications::Creator).to receive(:run).with(
      message: @message, user: @uwrs[0].user
    )
    expect(Mediators::Notifications::Creator).to receive(:run).with(
      message: @message, user: @uwrs[1].user
    )
    @plexer.call
  end
end
