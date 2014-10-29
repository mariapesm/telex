class Notification < Sequel::Model
  many_to_one :user
  many_to_one :message

  plugin :timestamps

end
