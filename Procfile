web: bundle exec puma --config config/puma.rb config.ru
worker: bundle exec sidekiq -g ${DYNO:-default} -i ${DYNO:-1} -r ./lib/application.rb
