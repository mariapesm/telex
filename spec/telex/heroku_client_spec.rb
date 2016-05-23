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

  it 'handles requests' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/organizations/foobar/members").
      to_return(status: 200, body: [{'id' => 1}].to_json)

    expect(client.organization_members('foobar')).to eql([{'id' => 1}])
  end

  it 'handles ranges' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/organizations/foobar/members").
      with(headers: {'Range'=>'id ..; max=1000;'}).
      to_return(
        status: 206,
        body: [{'id' => 1}].to_json,
        headers: {
          'Next-Range' => ']1..; max=1000;'
        }
      )

      stub_request(:get, "#{client.uri}/organizations/foobar/members").
        with(headers: {'Range'=>']1..; max=1000;'}).
        to_return(status: 206, body: [{'id' => 2}].to_json)

    expect(client.organization_members('foobar')).to eql([{'id' => 1}, {'id' => 2}])
  end

  it 'raises a NotFound error on 404s' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/organizations/foobar/members").
      to_return(status: 404)

    expect { client.organization_members('foobar') }.
      to raise_error(Telex::HerokuClient::NotFound)
  end
end
