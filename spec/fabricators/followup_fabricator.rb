Fabricator(:followup) do
  message
  body       { Faker::Company.bs }
end
