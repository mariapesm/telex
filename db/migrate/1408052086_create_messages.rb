Sequel.migration do
  change do
    create_table(:messages) do
      uuid        :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      uuid        :provider_uuid, null: false

      timestamptz :created_at, default: Sequel.function(:now), null: false
      text        :title, null: false
      text        :body,  null: false
    end
  end
end
