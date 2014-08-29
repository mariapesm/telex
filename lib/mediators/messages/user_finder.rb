module Mediators::Messages
  class UserFinder < Mediators::Base
    attr_accessor :target_id

    def self.from_message(message)
      type = message.target_type
      case type
      when 'user'
        UserUserFinder.new(target_id: message.target_id)
      when 'app'
        AppUserFinder.new(target_id: message.target_id)
      else
        raise "unknown message type: #{type}"
      end
    end

    def initialize(target_id:)
      self.target_id = target_id
    end

    def call
      get_users_from_heroku
      update_or_create_users
    end

    private

    def get_users_from_heroku  ; raise NotImplementedError end
    def update_or_create_users ; raise NotImplementedError end
  end

  class UserUserFinder < UserFinder
    private
    def get_users_from_heroku
      @user_response = Telex::HerokuClient.account_info(target_id)

      if @user_response['id'] != target_id
        raise "Mismatching ids, asked for #{target_id}, got #{@user_response['id']}"
      end
    end

    def update_or_create_users
      email = @user_response['email']
      id = @user_response['id']

      user = User[heroku_id: id]
      if user.nil?
        user = User.create(heroku_id: id, email: email)
      end
      user.email = email
      user.save_changes

      [user]
    end
  end

  class AppUserFinder < UserFinder

  end
end
