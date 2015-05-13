Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Telex::SidekiqInstrumenter
  end
end
