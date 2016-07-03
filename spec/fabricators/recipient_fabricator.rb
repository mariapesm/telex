Fabricator(:recipient) do
  app_id { SecureRandom.uuid }
  email { Faker::Internet.email }
  callback_url { "http://x.com/%{token}" }
  verification_token { SecureRandom.uuid }
  active { false }
  verified { false }
end
