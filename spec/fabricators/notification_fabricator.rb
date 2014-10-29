Fabricator(:notification) do
  message_id { SecureRandom.uuid }
  user_id    { SecureRandom.uuid }
end
