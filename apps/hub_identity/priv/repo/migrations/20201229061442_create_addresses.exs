defmodule HubIdentity.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :country, :string
      add :field_1, :string
      add :field_2, :string
      add :field_3, :string
      add :field_4, :string
      add :field_5, :string
      add :field_6, :string
      add :field_7, :string
      add :field_8, :string
      add :first_name, :string
      add :first_name_roman, :string
      add :last_name, :string
      add :last_name_roman, :string
      add :postal_code, :string
      add :uid, :string
      add :owner_uid, :string, null: false
      add :owner_type, :string, null: false
      add :deleted_at, :utc_datetime

      timestamps()
    end
  end
end
