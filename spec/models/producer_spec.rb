require "spec_helper"

describe Producer, '.find_by_creds' do
  let(:p) { Producer.create(name: 'foo', api_key: 'abc123') }

  it 'returns the producer if the creds match' do
    result = Producer.find_by_creds(id: p.id, api_key: 'abc123')
    expect(result.id).to_not be_nil
    expect(result.id).to eq(p.id)
  end

  it 'returns nil if the id is wrong' do
    result = Producer.find_by_creds(id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', api_key: 'abc123')
    expect(result).to be_nil
  end

  it 'returns nil if the api_key is wrong' do
    result = Producer.find_by_creds(id: p.id, api_key: 'wrong')
    expect(result).to be_nil
  end
end

describe Producer, '#api_key=' do
  it 'encrypts the api key' do
    p = Producer.new
    expect(p.encrypted_api_key).to be_nil
    p.api_key = 'foo'
    expect(p.encrypted_api_key).to_not be_nil
    expect(p.encrypted_api_key).to_not eq('foo')
  end
end
