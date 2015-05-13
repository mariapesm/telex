module Telex
  class SidekiqInstrumenter
    def call(worker, msg, queue, &block)
      begin
        Telex::Sample.measure("jobs.locked")
        Telex::Sample.measure("jobs.duration", &block)
        Telex::Sample.measure("jobs.success")
      rescue Exception
        Telex::Sample.measure("jobs.failure")
        raise
      end
    end
  end
end
