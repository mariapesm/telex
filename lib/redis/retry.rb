class Redis
  module Retry
    class Error < StandardError; end

    def redis_retry(**opts, &block)
      opts[:finish_time] ||= retry_window.seconds.from_now
      yield
    rescue Redis::BaseConnectionError => e
      if Time.now < opts[:finish_time]
        sleep(0.1)
        redis_retry(opts, &block)
      else
        raise Error, "Failed to connect to Redis after #{retry_window} seconds."
      end
    end

    def retry_window
      ENV.fetch("REDIS_RETRY_IN_SECONDS", 20).to_i
    end
  end
end
