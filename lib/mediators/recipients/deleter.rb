module Mediators::Recipients
  class Deleter < Base
    def call
      authorize!
      recipient.delete
    end
  end
end
