Sequel.migration do
  change do
    execute <<-SQL
      CREATE TYPE message_target AS ENUM ('user', 'app', 'resource');
    SQL

    create_table(:messages) do
      uuid           :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid           :producer_uuid, null: false
      timestamptz    :created_at,    null: false,  default: Sequel.function(:now)

      message_target :target_type,   null: false
      text           :target_id,     null: false

      text           :title,         null: false
      text           :body,          null: false
    end
  end
end
