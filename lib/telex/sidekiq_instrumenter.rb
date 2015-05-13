module Telex
  class SidekiqInstrumenter
    def call(worker, msg, queue, &block)
      begin
        Telex::Sample.measure("jobs.locked", units: "jobs")
        Telex::Sample.measure("jobs.duration", &block)
        Telex::Sample.measure("jobs.success", units: "jobs")
      rescue Exception
        Telex::Sample.measure("jobs.failure", units: "jobs")
        raise
      end
    end
  end
end
