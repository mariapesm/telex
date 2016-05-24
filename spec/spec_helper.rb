ENV["RACK_ENV"] = "test"

require "bundler"
Bundler.require(:default, :test, :development)

require 'dotenv'
Dotenv.load('.env.test')

require_relative "../config/config"
require_relative "../lib/initializer"

require 'sidekiq/testing'
require 'webmock/rspec'
# pull in test initializers
Pliny::Utils.require_glob("#{Config.root}/spec/support/**/*.rb")

RSpec.configure do |config|
  config.before :suite do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

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
