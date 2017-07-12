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
    Pliny::RequestStore.store[:request_id] = '12345'
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/teams/foobar/members").
      with(headers: {'Request-Id'=>'12345'}).
      to_return(status: 200, body: [{'id' => 1}].to_json)

    expect(client.team_members('foobar')).to eql([{'id' => 1}])
  end

  it 'passes the current request-id' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/teams/foobar/members").
      to_return(status: 200, body: [{'id' => 1}].to_json)

    expect(client.team_members('foobar')).to eql([{'id' => 1}])
  end

  it 'handles ranges' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/teams/foobar/members").
      with(headers: {'Range'=>'id ..; max=1000;'}).
      to_return(
        status: 206,
        body: [{'id' => 1}].to_json,
        headers: {
          'Next-Range' => ']1..; max=1000;'
        }
      )

      stub_request(:get, "#{client.uri}/teams/foobar/members").
        with(headers: {'Range'=>']1..; max=1000;'}).
        to_return(status: 206, body: [{'id' => 2}].to_json)

    expect(client.team_members('foobar')).to eql([{'id' => 1}, {'id' => 2}])
  end

  it 'raises a NotFound error on 404s' do
    client = Telex::HerokuClient.new
    stub_request(:get, "#{client.uri}/teams/foobar/members").
      to_return(status: 404)

    expect { client.team_members('foobar') }.
      to raise_error(Telex::HerokuClient::NotFound)
  end

  describe 'capabilities endpoint' do
    it 'returns true/false from matching response' do
      id = SecureRandom.uuid
      client = Telex::HerokuClient.new

      responses = [
        ['{ "capabilities": [{"capable": true}] }', true],
        ['{ "capabilities": [{"capable": false}] }', false],
      ]

      responses.each do |payload, capable|
        stub_request(:put, "#{client.uri}/users/~/capabilities").
          with(
            :body => {
              capabilities: [{
                capability: "view_metrics",
                resource_id: id,
                resource_type: "app"
              }]
            }.to_json
          ).to_return(:status => 200, :body => payload, :headers => {})

        expect(client.capable?(type: "app", id: id, capability: "view_metrics")).to eql(capable)
      end
    end

    it 'throws bad response on incomplete JSON payload response' do
      id = SecureRandom.uuid
      client = Telex::HerokuClient.new

      bad_responses = [
        '{}',
        '{ "capabilities": null }',
        '{ "capabilities": [] }',
      ]

      bad_responses.each do |bad_response|
        stub_request(:put, "#{client.uri}/users/~/capabilities").
          with(
            :body => {
              capabilities: [{
                capability: "view_metrics",
                resource_id: id,
                resource_type: "app"
              }]
            }.to_json
          ).to_return(:status => 200, :body => bad_response, :headers => {})

        expect { client.capable?(type: "app", id: id, capability: "view_metrics") }.
          to raise_error(Telex::HerokuClient::BadResponse)
      end
    end
  end
end
