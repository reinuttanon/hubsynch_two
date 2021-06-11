defmodule HubLedger.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :active, :boolean, default: true, null: false
      add :currency, :string
      add :kind, :string
      add :meta_data, :map, default: %{}
      add :name, :string
      add :owner, :map, default: %{}
      add :uuid, :string
      add :type, :string

      timestamps()
    end

    execute("CREATE INDEX accounts_owner ON accounts USING GIN(owner)")
  end
end
