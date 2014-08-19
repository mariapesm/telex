module Mediators::Messages
  class Creator < Mediators::Base
    def initialize(producer: producer, title:, body:, target_type:, target_id:)
      @message = Message.new(
                   producer_uuid: producer.uuid,
                   title: title,
                   body: body,
                   target_type: target_type,
                   target_id: target_id)
    end

    def call
      @message.save
    end
  end
end
