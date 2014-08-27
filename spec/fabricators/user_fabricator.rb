Fabricator(:user) do
  heroku_id { SecureRandom.uuid }
end
