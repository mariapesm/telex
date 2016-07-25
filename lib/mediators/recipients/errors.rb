class Mediators
  module Recipients
    NotFound = Class.new(StandardError)
    BadRequest = Class.new(StandardError)
    LimitError = Class.new(StandardError)
  end
end
