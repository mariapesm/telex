Sequel.migration do
  change do
    add_column :notifications, :read_at, :timestamptz
  end
end
