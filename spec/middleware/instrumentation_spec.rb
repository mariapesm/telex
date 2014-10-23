require "spec_helper"

describe Middleware::Instrumentation do
  def app
    Rack::Builder.new do
      use Rack::Lint
      use Middleware::Instrumentation
      run Sinatra.new {
        get "/foo" do
          200
        end
      }
    end
  end

  before do
    # need to stub otherwise mocks are going to fail
    # when these are called with different params:
    allow(Telex::Sample).to receive(:count)
    allow(Telex::Sample).to receive(:measure)
  end

  it "counts requests" do
    expect(Telex::Sample).to receive(:count).with("requests")
    get "/foo"
  end

  it "counts requests by the status code" do
    expect(Telex::Sample).to receive(:count).with("requests.200")
    get "/foo"
  end

  it "measures latency" do
    expect(Telex::Sample).to receive(:measure).with("requests.latency", anything)
    get "/foo"
  end
end
