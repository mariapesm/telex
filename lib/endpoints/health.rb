module Endpoints
  class Health < Base
    get "/health" do
      begin
        User.db.execute("SELECT 1")
        ""
      rescue Sequel::DatabaseError
        halt 503
      end
    end
  end
end
