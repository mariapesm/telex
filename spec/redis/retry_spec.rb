require 'spec_helper'

describe Redis::Retry do
  describe "#redis_retry" do
    subject { RedisRetryTest.new }

    it "raises Redis::Retry::Error if a connection couldn't be established" do
      allow(subject).to receive(:something_that_uses_redis).and_raise(Redis::BaseConnectionError)
      expect { subject.call }.to raise_error(Redis::Retry::Error)
    end

    it "yields if redis is functioning" do
      allow(subject).to receive(:something_that_uses_redis).and_return("works")
      expect(subject.call).to eq("works")
    end
  end
end

class RedisRetryTest
  include Redis::Retry

  def call
    redis_retry do
      something_that_uses_redis
    end
  end
end
