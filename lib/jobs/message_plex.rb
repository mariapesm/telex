module Jobs
  class MessagePlex
    include Sidekiq::Worker

    def perform(message_id)
      message = Message[id: message_id]
      Mediators::Messages::Plexer.run(message: message)
    end
  end
end
