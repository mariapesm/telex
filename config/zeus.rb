require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def boot

  end

  def test
    require_relative "../spec/spec_helper"
  end

  def rspec(argv=ARGV)
    exit RSpec::Core::Runner.run(argv)
  end

  def after_fork
    reconnect_sequel
    reconnect_redis
  end

  private
  def reconnect_sequel
    return unless defined?(Sequel)
    Sequel::DATABASES.each { |db| db.disconnect }
  end

end

Zeus.plan = CustomPlan.new
