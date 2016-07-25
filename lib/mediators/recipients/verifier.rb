module Mediators::Recipients
  class Verifier < Mediators::Base
    attr_reader :recipient, :token

    def initialize(recipient:, token:)
      @recipient = recipient
      @token = token
    end

    def call
      raise Mediators::Recipients::NotFound unless recipient.valid_token?(token)

      recipient.update(verified: true, active: true)
    end
  end
end
