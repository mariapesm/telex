class Followup < Sequel::Model
  plugin :timestamps
  plugin :validation_helpers

  def validate
    super
    validates_presence %i(message_id body)
  end
end
