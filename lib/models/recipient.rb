class Recipient < Sequel::Model
  VERIFICATION_TOKEN_TTL = 7200

  EMAIL = /@/

  plugin :timestamps
  plugin :validation_helpers

  def self.find_active_by_app_id(app_id:)
    self.where(app_id: app_id, active: true, verified: true)
  end

  def self.verify(app_id:, id:, verification_token:)
    return unless recipient = self[app_id: app_id, id: id]
    return unless recipient.verification_token == verification_token
    return if recipient.verification_token_expired?

    return recipient
  end

  def self.generate_token
    SecureRandom.hex(3)[0,5].upcase
  end

  def validate
    super
    validates_presence %i(app_id callback_url email)
    validates_format EMAIL, :email
    validates_format URI.regexp, :callback_url
  end

  def verification_token_expired?
    (Time.now.utc - verification_sent_at) > VERIFICATION_TOKEN_TTL
  end
end
