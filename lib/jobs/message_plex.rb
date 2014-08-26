class MessagePlex
  include Sidekiq::Worker

  def perform(message_id)

  end
end
