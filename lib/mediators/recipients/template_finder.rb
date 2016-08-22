module Mediators::Recipients
  class TemplateFinder < Mediators::Base
    KEY = "%s_CONFIRMATION_EMAIL_%s"

    def initialize(template:)
      @template = template.upcase
    end

    def call
      begin
        @title = ENV.fetch(KEY % [@template, "TITLE"])
        @body  = ENV.fetch(KEY % [@template, "BODY"])
      rescue KeyError
        raise Mediators::Recipients::NotFound
      else
        return @title, @body
      end
    end
  end
end
