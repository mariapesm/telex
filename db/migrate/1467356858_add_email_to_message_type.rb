Sequel.migration do
  no_transaction
  change do
    execute <<-SQL
      ALTER TYPE message_target ADD VALUE 'email';
    SQL
  end
end
