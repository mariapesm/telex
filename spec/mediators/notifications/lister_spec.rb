require "spec_helper"

describe Mediators::Notifications::Lister, '#call' do
  let(:lister) { described_class.new(user: @user) }

  before do
    @user = Fabricate(:user)
  end

  context 'a user with no notifications' do
    it 'returns an empty array' do
      expect(lister.call).to eq([])
    end
  end

  context 'a user with notificatons' do
    before do
      @p1 = Fabricate(:producer)
      @m1 = Fabricate(:message, producer_id: @p1.id)
      @m2 = Fabricate(:message, producer_id: @p1.id)
      @f1 = Fabricate(:followup, message_id: @m1.id)
      @n1 = Fabricate(:notification, user_id: @user.id, message_id: @m1.id, created_at: DateTime.new(2012,2,2))
      @n2 = Fabricate(:notification, user_id: @user.id, message_id: @m2.id, created_at: DateTime.new(2014,4,4))
    end

    it 'returns the notifications in a sorted array' do
      expect(@n2.created_at).to be > @n1.created_at
      expect(lister.call).to eq([@n2, @n1])
    end

    it 'does not include notificaitons for other users' do
      user2 = Fabricate(:user)
      note = Fabricate(:notification, user_id: user2.id, message_id: @m1.id, created_at: DateTime.new(2012,2,2))

      expect(lister.call).to_not include(note)
    end

    it 'only makes one query even when the associated parts are touched' do
      selects = count_selects do
        result = lister.call
        result.first.message
        result.first.message.body
        result.first.message.title
        result.first.message.followup
        result.last.message
        result.last.message.body
        result.last.message.title
        result.last.message.followup
        result.last.message.followup.first.body
      end

      expect(selects).to eq(1)
    end

    it 'returns something that works with the Serializer' do
      sz = Serializers::UserAPI::Notification.new(:default)
      json = MultiJson.encode(sz.serialize(lister.call))
      expect(json).to include(@m1.body)
      expect(json).to include('2012-02-02T00:00:00Z')
    end
  end
end
