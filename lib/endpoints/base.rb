module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Sinatra::Namespace

    helpers Pliny::Helpers::Encode
    helpers Pliny::Helpers::Params
    helpers Pliny::Helpers::Serialize

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
      also_reload "#{Config.root}/lib/**/*.rb"
    end

    error Sinatra::NotFound do
      raise Pliny::Errors::NotFound
    end

    error Pliny::Errors::HTTPStatusError do
      # Set the error status here so Pliny::Extensions::Instruments reports it
      # properly.
      status env["sinatra.error"].status
      # Re-raising so Pliny::Middleware::RescueErrors can handle it.
      raise env["sinatra.error"]
    end
  end
end
