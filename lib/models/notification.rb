class Notification < Sequel::Model
  many_to_one :user
  many_to_one :message

  plugin :timestamps
  plugin :validation_helpers

  def validate
    super
    validates_unique %i[user message]
  end
end
