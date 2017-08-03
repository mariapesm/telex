module Serializers::ProducerAPI
  class UserWithRoleSerializer < Serializers::Base
    structure(:default) do |r|
      {
        role: r.role,
        user: {
          email: r.user.email,
          id: r.user.id
        }
      }
    end
  end
end
