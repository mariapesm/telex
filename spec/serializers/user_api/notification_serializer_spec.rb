require "spec_helper"

describe Serializers::UserAPI::NotificationSerializer do
  let(:sz) { described_class.new(:default) }

  before do
    @note = Fabricate(:notification, created_at: DateTime.new(2012,2,2))
    @notes = Mediators::Notifications::Lister.run(user: @note.user)
  end

  it 'can use whatever the lister mediator generates' do
    json = MultiJson.encode(sz.serialize(@notes))
    expect(json).to match(@note.message.body)
    expect(json).to match('2012-02-02T00:00:00Z') # the Z is required for firefox!
  end

  it 'adds read based on read_at' do
    @notes.first.read_at = nil
    response = sz.serialize(@notes)
    expect(response.first.fetch(:read)).to eq(false)

    @notes.first.read_at = Time.now
    response = sz.serialize(@notes)
    expect(response.first.fetch(:read)).to eq(true)
  end
end
