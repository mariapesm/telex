module Mediators::Recipients
  class Lister < Base
    def call
      authorize!
      Recipient.where(app_id: app_id)
    end
  end
end
