class Notification < Sequel::Model
  many_to_one :user
  many_to_one :recipient
  many_to_one :message

  plugin :timestamps
  plugin :validation_helpers

  def validate
    super
    if user
      validates_unique %i[user message]
    elsif recipient
      validates_unique %i[recipient message]
    end
  end

  def notifiable
    user || recipient
  end
end
