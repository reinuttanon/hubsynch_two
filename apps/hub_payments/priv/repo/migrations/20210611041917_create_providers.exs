defmodule HubPayments.Repo.Migrations.CreateProviders do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :name, :string
      add :credentials, :map, default: %{}
      add :url, :string
      add :active, :boolean, default: false, null: false
      add :uuid, :string

      timestamps()
    end

  end
end
