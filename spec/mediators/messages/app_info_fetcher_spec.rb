require "spec_helper"
include Mediators::Messages

describe AppInfoFetcher, "#call" do
  before do
    @id = SecureRandom.uuid
    stub_heroku_api
    @fetcher = AppInfoFetcher.new(target_id: @id)
  end

  it "creates the user locally if needed" do
    result = @fetcher.call
    expect(result.name).to eq("example")
  end
end
