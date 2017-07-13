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

    error Excon::Errors::Unauthorized do
      status 401
    end

    error Excon::Errors::Forbidden do
      status 403
    end

    error Sinatra::NotFound, Mediators::Recipients::NotFound, Excon::Errors::NotFound, Pliny::Errors::NotFound do
      status 404
    end

    error Mediators::Recipients::LimitError do
      status 429
      { "id": "bad_request", "message": sinatra_error.message }.to_json
    end

    error MultiJson::ParseError, Sequel::ValidationFailed, Sequel::UniqueConstraintViolation, Mediators::Recipients::BadRequest do
      status 400
      { "id": "bad_request", "message": bad_request_message }.to_json
    end
  end
end
