module Mediators::Messages
  class Cleanup < Mediators::Base
    def call
      db = Sequel::Model.db
      db.transaction do
        db["DELETE FROM followups
              USING messages
              WHERE messages.id=followups.message_id
                AND messages.created_at < now()-'3 months'::interval"].all
        db["DELETE FROM notifications
              USING messages
              WHERE messages.id=notifications.message_id
                AND messages.created_at < now()-'3 months'::interval"].all
        db["DELETE FROM messages
              WHERE messages.created_at < now()-'3 months'::interval"].all
      end
    end
  end
end
