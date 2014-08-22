class Producer < Sequel::Model
  plugin :timestamps

  def self.find_by_creds(id:, api_key:)
    canididate = self[id: id]
    return nil unless canididate && Telex::ApiKey.compare(canididate.encrypted_api_key, api_key)
    canididate
  end

  def api_key=(raw_key)
    self.encrypted_api_key = Telex::ApiKey.encrypt(raw_key)
  end
end
