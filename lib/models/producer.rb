require 'bcrypt'

class Producer < Sequel::Model
  plugin :timestamps

  def self.find_by_creds(uuid:, api_key:)
    canididate = self[uuid: uuid]
    return nil unless canididate && BCrypt::Password.new(canididate.encrypted_api_key) == api_key
    canididate
  end

  def api_key=(raw_key)
    self.encrypted_api_key = BCrypt::Password.create(raw_key)
  end
end
