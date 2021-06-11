defmodule HubPayments.Repo.Migrations.CreateCreditCards do
  use Ecto.Migration

  def change do
    create table(:credit_cards) do
      add :brand, :string
      add :exp_month, :string
      add :exp_year, :string
      add :fingerprint, :string
      add :last_four, :string
      add :uuid, :string
      add :wallet_id, references(:wallets, on_delete: :nothing)

      timestamps()
    end

    create index(:credit_cards, [:wallet_id])
  end
end
