module Middleware
  class Instrumentation
    def initialize(app)
      @app = app
    end

    def call(env)
      start = Time.now
      status, headers, response = @app.call(env)
      elapsed = (Time.now - start).to_f

      status_group = "#{status / 100}0x"
      Telex::Sample.count "requests"
      Telex::Sample.count "requests.#{status_group}"
      Telex::Sample.measure "requests.latency", value: elapsed, unit: "s"

      [status, headers, response]
    end
  end
end
