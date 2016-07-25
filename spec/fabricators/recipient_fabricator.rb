Fabricator(:recipient) do
  app_id { SecureRandom.uuid }
  email { Faker::Internet.email }
  verification_token { Recipient.generate_token }
  active { false }
  verified { false }
end
