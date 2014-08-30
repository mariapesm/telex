module Mediators::Messages
  class UserFinder < Mediators::Base
    UserWithRole = Struct.new(:role, :user)

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
      update_or_create_all_users
    end

    private
    attr_accessor :users_details

    def get_users_from_heroku  ; raise NotImplementedError end

    def update_or_create_all_users
      users_details.map do |details|
        user = update_or_create_user(hid: details[:hid], email: details[:email])
        role = details[:role]
        UserWithRole.new(role, user)
      end
    end

    def update_or_create_user(hid:, email:)
      user = User[heroku_id: hid]
      if user.nil?
        user = User.create(heroku_id: hid, email: email)
      end
      user.email = email
      user.save_changes
      user
    end

    def extract_user(role, response)
      { role: role,
        email: response.fetch('email'),
        hid: response.fetch('id')
      }
    end
  end

  class UserUserFinder < UserFinder
    private
    def get_users_from_heroku
      user_response = Telex::HerokuClient.account_info(target_id)

      id = user_response.fetch('id')
      if id != target_id
        raise "Mismatching ids, asked for #{target_id}, got #{id}"
      end

      self.users_details = [ extract_user(:self, user_response) ]
    end
  end

  class AppUserFinder < UserFinder
    private
    def get_users_from_heroku
      owner_response  = Telex::HerokuClient.app_info(target_id)
      collab_response = Telex::HerokuClient.app_collaborators(target_id)

      owner = extract_user(:owner, owner_response.fetch('owner') )
      collabs = collab_response.map do |row|
        extract_user(:collaborator, row.fetch('user'))
      end

      self.users_details = [owner] + collabs
    end
  end
end
