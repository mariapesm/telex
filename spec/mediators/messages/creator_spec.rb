require "spec_helper"

describe Mediators::Messages::Creator do
  it 'creates a message' do
    creator = described_class.new(producer: double('producer', id: SecureRandom.uuid),
                                  title: Faker::Company.bs,
                                  body: Faker::Company.catch_phrase,
                                  target_type: 'user',
                                  target_id: SecureRandom.uuid)

    result = nil
    expect{ result = creator.call }.to change(Message, :count).by(1)
    expect(result).to be_instance_of(Message)
  end
end
