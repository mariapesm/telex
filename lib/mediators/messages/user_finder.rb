module Mediators::Messages
  class UserFinder < Mediators::Base
    attr_accessor :target_id

    def self.from_message(message)
      type = message.target_type
      case type
      when Message::USER
        UserUserFinder.new(target_id: message.target_id)
      when Message::APP
        AppUserFinder.new(target_id: message.target_id)
      when Message::EMAIL
        EmailUserFinder.new(target_id: message.target_id)
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

    def heroku_client
      Telex::HerokuClient.new
    end

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

  class EmailUserFinder < UserFinder
    private
    # this is more to comply with the existing interface, but we're not really getting
    # any users from the API.
    def get_users_from_heroku
      self.users_details = Recipient.find_active_by_app_id(app_id: target_id).map do |r|
        extract_user(:self, { "email" => r.email, "id" => r.id })
      end
    end

    def update_or_create_user(hid:, email:)
      # Fake the user via Recipient since they share the same interface
      Recipient[hid]
    end
  end

  class UserUserFinder < UserFinder
    private
    def get_users_from_heroku
      user_response = heroku_client.account_info(user_uuid: target_id)

      id = user_response.fetch('id')

      if id != target_id
        raise "Mismatching ids, asked for #{target_id}, got #{id}"
      end

      if user_response.fetch('last_login')
        self.users_details = [ extract_user(:self, user_response) ]
      else
        self.users_details = [ ]
      end
    rescue Telex::HerokuClient::NotFound
      self.users_details = [ ]
      Telex::Sample.count "user_not_found"
    end
  end

  class AppUserFinder < UserFinder
    private
    def get_users_from_heroku
      if app_info.nil?
        self.users_details = [ ]
        return
      end

      self.users_details = (owners + collabs).uniq {|u| u[:email] }.select do |user|
        # This filters out users who have never logged in
        UserUserFinder.run(target_id: user[:hid]).present?
      end
    end

    def app_info
      @app_info ||= heroku_client.app_info(target_id)
    rescue Telex::HerokuClient::NotFound
      Pliny.log(missing_app: true, app_id: target_id)
      Telex::Sample.count "app_not_found"
      nil
    end

    def owners
      owner = extract_user(:owner, app_info.fetch('owner'))
      if owner[:email].end_with?('@herokumanager.com')
        org_users(owner[:email])
      else
        [ owner ]
      end
    end

    def org_users(owner_email)
      org_members_response = heroku_client.organization_members(owner_email.split('@').first)
      org_admins = org_members_response.select { |member| member.fetch('role') == 'admin' }
      org_admins.map do |admin|
        extract_user(:owner, admin.fetch('user'))
      end
    rescue Telex::HerokuClient::NotFound
      # Organization is missing
      Pliny.log(missing_org: true, org: owner_email)
      Telex::Sample.count "org_not_found"
      []
    end

    def collabs
      collab_response = heroku_client.app_collaborators(target_id)
      collab_response.map do |row|
        extract_user(:collaborator, row.fetch('user'))
      end.compact
    rescue Telex::HerokuClient::NotFound
      # Between the time we looked up the app in app_info and now, the app
      # has been deleted.
      # Don't bother sampling since this is only a fluke.
      Pliny.log(missing_app_on_collab_lookup: true, app_id: target_id)
      []
    end
  end
end
