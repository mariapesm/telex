module Mediators::Messages
  class Creator < Mediators::Base
    def initialize(producer:, title:, body:, action_label:, action_url:, target_type:, target_id:)
      @args = {
        producer_id: producer.id,
        title: title,
        body: body,
        action_label: action_label,
        action_url: action_url,
        target_type: target_type,
        target_id: target_id
      }
    end

    def call
      Message.new(@args).save
      Pliny.log(@args.merge(messages_creator: true, telex: true))
      Jobs::MessagePlex.perform_async(@message.id)
      Telex::Sample.count "messages"
      @message
    end
  end
end
