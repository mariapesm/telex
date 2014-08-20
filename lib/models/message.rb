class Message < Sequel::Model
  plugin :timestamps
  plugin :validation_helpers

  def validate
    super
    validates_presence %i(target_type target_id title body producer_id)
  end
end
