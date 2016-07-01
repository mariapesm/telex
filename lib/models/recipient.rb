class Recipient < Sequel::Model
  VERIFICATION_TOKEN_TTL = 7200

  EMAIL = /\A([\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+\.)*
           [\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+@
           ((((([a-z0-9]{1}[a-z0-9\-]{0,62}[a-z0-9]{1})|[a-z])\.)+
           [a-z]{2,12})|(\d{1,3}\.){3}\d{1,3}(\:\d{1,5})?)\z/ix

  URL = /\A(http|https):\/\/([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,12}|(2
         5[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}
         |localhost)(:[0-9]{1,5})?(\/.*)?\z/ix

  TOKEN = %r(%{token})
  ID = %r(%{id})

  plugin :timestamps
  plugin :validation_helpers

  def self.find_active_by_app_id(app_id:)
    self.where(app_id: app_id, active: true, verified: true)
  end

  def self.find_by_id_and_verification_token(id:, verification_token:)
    return unless recipient = self[id]
    return unless recipient.verification_token == verification_token
    return if recipient.verification_token_expired?

    return recipient
  end

  def validate
    super
    validates_presence %i(app_id callback_url email)
    validates_format EMAIL, :email
    validates_format URL, :callback_url
    validates_format TOKEN, :callback_url
    validates_format ID, :callback_url
  end

  def verification_token_expired?
    (Time.now.utc - verification_sent_at) > VERIFICATION_TOKEN_TTL
  end
end
