Sequel.migration do
  change do
    create_table(:messages) do
      uuid          :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      provider_uuid :uuid, null: false

      timestamptz   :created_at, default: Sequel.function(:now), null: false
      title         :text, null: false
      body          :text, null: false
    end
  end
end
