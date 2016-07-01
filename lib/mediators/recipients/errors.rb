class Mediators
  module Recipients
    Forbidden = Class.new(StandardError)
    NotFound = Class.new(StandardError)
  end
end
