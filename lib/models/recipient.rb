class Recipient < Sequel::Model
  VERIFICATION_TOKEN_TTL = 7200

  EMAIL = /@/
  TOKEN = %r(%{token})

  plugin :timestamps
  plugin :validation_helpers

  def self.find_active_by_app_id(app_id:)
    self.where(app_id: app_id, active: true, verified: true)
  end

  def self.find_by_app_id_and_verification_token(app_id:, verification_token:)
    return unless recipient = self[app_id: app_id, verification_token: verification_token]
    return if recipient.verification_token_expired?

    return recipient
  end

  def validate
    super
    validates_presence %i(app_id callback_url email)
    validates_format EMAIL, :email
    validates_format URI.regexp, :callback_url
    validates_format TOKEN, :callback_url
  end

  def verification_token_expired?
    (Time.now.utc - verification_sent_at) > VERIFICATION_TOKEN_TTL
  end

  def verification_url
    callback_url % { token: verification_token }
  end
end
