module Mediators::Recipients
  class Updater < Mediators::Base
    attr_reader :recipient, :active, :callback_url

    def initialize(recipient:, callback_url:, active: false)
      @recipient = recipient
      @callback_url = callback_url
      @active = active      
    end

    def call
      recipient.update(active: active, callback_url: callback_url)
    end
  end
end
