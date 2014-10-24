require 'spec_helper'

describe Telex::HerokuClient, '#new' do
  it 'uses config for the default uri' do
    uri_string = Telex::HerokuClient.new.uri.to_s
    expect(uri_string).to eq(Config.heroku_api_url)
    expect(uri_string).to_not be_blank
  end

  it 'allows subsutition of another api key' do
    key = SecureRandom.uuid
    uri = Telex::HerokuClient.new(api_key: key).uri
    expect(uri.to_s).to_not eq(Config.heroku_api_url)
    expect(uri.password).to eq(key)
  end
end
