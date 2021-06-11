defmodule HubLedger.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :deleted_at, :utc_datetime
      add :role, :string
      add :uuid, :string, null: false
      add :hub_identity_uid, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:hub_identity_uid])
  end
end
