defmodule HubLedger.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :active, :boolean, default: true, null: false
      add :kind, :string
      add :money, :map, default: %{}
      add :uuid, :string
      add :account_id, references(:accounts, on_delete: :nothing)

      timestamps()
    end

    create index(:balances, [:account_id])
    execute("CREATE INDEX balances_money ON balances USING GIN(money)")
  end
end
