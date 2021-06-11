defmodule HubLedger.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :money, :map, default: %{}
      add :description, :string
      add :kind, :string
      add :reported_date, :utc_datetime
      add :uuid, :string
      add :account_id, references(:accounts, on_delete: :nothing)
      add :entry_id, references(:entries, on_delete: :nothing)

      timestamps()
    end

    create index(:transactions, [:account_id])
    create index(:transactions, [:entry_id])

    execute("CREATE INDEX transactions_money ON transactions USING GIN(money)")
  end
end
