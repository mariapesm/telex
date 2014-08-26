Fabricator(:message) do
  producer_id { SecureRandom.uuid }
  target_type { 'user' }
  target_id   { SecureRandom.uuid }
  title       { Faker::Company.bs }
  body        { Faker::Company.bs }
end
