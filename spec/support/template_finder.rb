module Mediators::Recipients
  class TemplateFinder
    def self.setup(template:, title:, body:)
      begin
        ENV[KEY % [template.upcase, "TITLE"]] = title
        ENV[KEY % [template.upcase, "BODY"]] = body
      ensure
        ENV.delete(KEY % [template.upcase, "TITLE"])
        ENV.delete(KEY % [template.upcase, "BODY"])
      end
    end
  end
end

