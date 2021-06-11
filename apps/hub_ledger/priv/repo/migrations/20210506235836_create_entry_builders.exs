defmodule HubLedger.Repo.Migrations.CreateEntryBuilders do
  use Ecto.Migration

  def change do
    create table(:entry_builders) do
      add :active, :boolean, default: true, null: false
      add :name, :string
      add :json_config, :map
      add :uuid, :string

      timestamps()
    end
  end
end
