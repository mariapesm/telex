require 'clockwork'
require_relative 'application'
require 'sidekiq/api'

module Clockwork
  every(10.seconds, 'monitor_queue') do
    stats = Sidekiq::Stats.new
    Telex::Sample.count "jobs.queue", value: stats.enqueued
  end
end
