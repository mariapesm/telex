ENV["RACK_ENV"] = "test"
ENV["ADDITIONAL_API_HEADERS"] = "User: {{user}}"

require "bundler"
Bundler.require(:default, :test)

root = File.expand_path("../../", __FILE__)
ENV.update(Pliny::Utils.parse_env("#{root}/.env.test"))

require_relative "../lib/initializer"

require 'sidekiq/testing'
require 'webmock/rspec'

DatabaseCleaner.strategy = :transaction

# pull in test initializers
Pliny::Utils.require_glob("#{Config.root}/spec/support/**/*.rb")

RSpec.configure do |config|
  config.before :all do
    load('db/seeds.rb') if File.exist?('db/seeds.rb')
  end

  config.before :each do
    Mail::TestMailer.deliveries.clear
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  # the rack app to be tested with rack-test:
  def app
    @rack_app || fail("Missing @rack_app")
  end
end
