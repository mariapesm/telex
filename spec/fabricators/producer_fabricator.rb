Fabricator(:producer) do
  name { Faker::Company.name }
  api_key { 'super secret' }
end
