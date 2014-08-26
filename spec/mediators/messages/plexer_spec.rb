require "spec_helper"

describe Mediators::Messages::Plexer, '#get_users' do
  before do
    @message = instance_double(Message)
    @user_finder = double('user finder')
    @plexer = described_class.new(message: @message, user_finder: @user_finder)
  end

  it 'uses the user finder to set users' do
    expect(@plexer.user_ids).to eq([])
    expect(@user_finder).to receive(:call).with(@message).and_return(['id1', 'id2'])
    @plexer.get_users
    expect(@plexer.user_ids).to eq(['id1', 'id2'])
  end

end
