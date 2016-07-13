Fabricator(:recipient) do
  app_id { SecureRandom.uuid }
  email { Faker::Internet.email }
  callback_url { "http://dashboard.heroku.com/" }
  verification_token { Recipient.generate_token }
  active { false }
  verified { false }
end
