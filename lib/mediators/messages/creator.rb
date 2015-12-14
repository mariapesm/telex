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
      Message.new(@args).tap do |msg|
        msg.save
        Pliny.log(@args.merge(messages_creator: true, telex: true))
        Jobs::MessagePlex.perform_async(msg.id)
        Telex::Sample.count "messages"
      end
    end
  end
end
