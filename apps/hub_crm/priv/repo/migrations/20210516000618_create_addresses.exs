defmodule HubCrm.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :address_1, :string
      add :address_2, :string
      add :address_3, :string
      add :address_4, :string
      add :address_5, :string
      add :country, :string
      add :postal_code, :string
      add :default, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :uuid, :string

      timestamps()
    end

    create index(:addresses, [:user_id])
  end
end
