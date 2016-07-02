module Serializers::AppAPI
  class RecipientSerializer < Serializers::Base
    structure(:default) do |r|
      {
        id:               r.id,
        email:            r.email,
        verification_url: r.verification_url,
        active:           r.active,
        verified:         r.verified,
        created_at:       time_format(r.created_at),
      }
    end
  end
end
