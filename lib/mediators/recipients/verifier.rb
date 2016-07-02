module Mediators::Recipients
  class Verifier < Mediators::Base
    attr_reader :recipient

    def initialize(recipient:)
      @recipient = recipient
    end

    def call
      recipient.update(verified: true, active: true)
    end
  end
end
