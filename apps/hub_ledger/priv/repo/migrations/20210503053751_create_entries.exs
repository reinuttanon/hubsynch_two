defmodule HubLedger.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :description, :string
      add :owner, :map, default: %{}
      add :reported_date, :utc_datetime
      add :uuid, :string

      timestamps()
    end

    execute("CREATE INDEX entries_owner ON entries USING GIN(owner)")
  end
end
