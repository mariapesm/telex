require "spec_helper"

include Mediators::Messages

describe Plexer, '#call' do
  before do
    @message = instance_double(Message)
    @plexer = Plexer.new(message: @message)
  end

  it 'uses the user finder to set @users' do
    user_finder = double('user finder')
    @plexer.user_finder = user_finder
    users = Array.new(2) { instance_double(User) }

    expect(@plexer.users).to eq([])
    expect(user_finder).to receive(:call).with(@message).and_return( users )
    @plexer.call
    expect(@plexer.users).to eq(users)
  end

  it 'picks the appropriate user finder'

  it 'creates a Notificaton for each user' do
    users = Array.new(2) { instance_double(User) }
    @plexer.user_finder = double('user finder', call: users)

    expect(Mediators::Notifications::Creator).to receive(:run).with(message: @message, user: users[0])
    expect(Mediators::Notifications::Creator).to receive(:run).with(message: @message, user: users[1])
    @plexer.call
  end

end
