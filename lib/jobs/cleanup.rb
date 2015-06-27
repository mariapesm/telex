module Jobs
  class Cleanup
    include Sidekiq::Worker

    def perform
      Mediators::Messages::Cleanup.run
    end
  end
end
