require "spec_helper"

include Mediators::Messages

describe Plexer, '#call' do
  before do
    @message = instance_double(Message)
    @plexer = Plexer.new(message: @message)
    @plexer.user_finder = double('null user finder', call: [])
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


end


