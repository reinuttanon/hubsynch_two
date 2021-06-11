defmodule HubIdentity.Repo.Migrations.CreateTelephones do
  use Ecto.Migration

  def change do
    create table(:telephones) do
      add :number, :string
      add :type, :string
      add :uid, :string
      add :owner_uid, :string, null: false
      add :owner_type, :string, null: false
      add :deleted_at, :utc_datetime

      timestamps()
    end
  end
end
