module Mediators::Recipients
  class Verifier < Base
    def call
      authorize!
      raise NotFound unless recipient = find_by_token
      recipient.update(verified: true)
    end

    def find_by_token
      Recipient.find_by_id_and_verification_token(id: recipient.id, verification_token: token)
    end
  end
end
