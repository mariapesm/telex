module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Pliny::Extensions::Instruments
    register Sinatra::Namespace

    helpers Pliny::Helpers::Encode
    helpers Pliny::Helpers::Params

    helpers do
      def data
        MultiJson.decode(request.body.read).tap do
          request.body.rewind
        end
      end
    end

    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false

    configure :development do
      register Sinatra::Reloader
      also_reload '../**/*.rb'
    end

    error Pliny::Errors::HTTPStatusError do
      err = env["sinatra.error"]
      # Set the error status here so Pliny::Extensions::Instruments reports it
      # properly.
      status err.status
      # Re-raising so Pliny::Middleware::RescueErrors can handle it.
      raise err
    end

    not_found do
      content_type :json
      status 404
      "{}"
    end
  end
end
