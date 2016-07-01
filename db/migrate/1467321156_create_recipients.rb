Sequel.migration do
  up do
    execute 'create extension if not exists "uuid-ossp"'
    create_table(:recipients) do
      uuid         :id, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid         :app_id, null: false
      text         :email, null: false
      uuid         :verification_token, default: Sequel.function(:uuid_generate_v4), null: false
      timestamptz  :verification_sent_at, default: Sequel.function(:now), null: false
      bool         :verified, default: false, null: false
      bool         :active, default: false, null: false
      text         :callback_url, null: false
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at
    end

    # Need to be able to find all recipients for a given app
    add_index :recipients, :app_id
    add_index :recipients, [:app_id, :email], unique: true
  end

  down do
    execute 'drop extension "uuid-ossp"'
    execute 'drop table recipients'
  end
end
