require 'spec_helper'

describe Telex::ApiKey, '.generate' do
  it 'hmacs the input' do
    input = 'foo'
    output1 = Telex::ApiKey.generate(input)
    output2 = Telex::ApiKey.generate(input)

    expect(output1).to_not eq(input)
    expect(output1).to eq(output2)
  end
end

describe Telex::ApiKey, '.compare' do
  it 'verifies an api key' do
    input = 'foo'
    encrypted = Telex::ApiKey.generate(input)

    expect(Telex::ApiKey.compare(encrypted, input)).to eq(true)
    expect(Telex::ApiKey.compare(encrypted, 'incorrect')).to eq(false)
  end
end
