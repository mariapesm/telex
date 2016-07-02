module Mediators::Recipients
  class Deleter < Mediators::Base
    attr_reader :recipient

    def initialize(recipient:)
      @recipient = recipient 
    end

    def call
      recipient.delete
    end
  end
end
