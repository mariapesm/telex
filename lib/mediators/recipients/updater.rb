module Mediators::Recipients
  class Updater < Base
    def call
      authorize!
      recipient.update(active: active, callback_url: callback_url)
    end
  end
end
