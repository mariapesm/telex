Sequel.migration do
  no_transaction
  change do
    execute <<-SQL
      ALTER TYPE message_target ADD VALUE 'dashboard';
    SQL
  end
end
