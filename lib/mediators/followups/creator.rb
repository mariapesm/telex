module Mediators::Followups
  class Creator < Mediators::Base
    def initialize(message:, body:)
      @followup = Followup.new(message_id: message.id, body: body)
    end

    def call
      @followup.save
    end
  end
end
