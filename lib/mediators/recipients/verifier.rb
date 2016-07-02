module Mediators::Recipients
  class Verifier < Mediators::Base
    attr_reader :recipient, :token

    def initiaize(recipient:, token:)
      @recipient = recipient
      @token = token      
    end

    def call
      raise NotFound unless recipient = find_by_token
      recipient.update(verified: true)
    end

    def find_by_token
      Recipient.find_by_id_and_verification_token(id: recipient.id, verification_token: token)
    end
  end
end
