defmodule HubPayments.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :owner, :map, default: %{}
      add :prefered_credit_card_uuid, :string
      add :uuid, :string

      timestamps()
    end

  end
end
