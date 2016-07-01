module Mediators::Recipients
  class Creator < Base
    def call
      authorize!
      Recipient.create(email: email, app_id: app_id, callback_url: callback_url)
    end
  end
end
