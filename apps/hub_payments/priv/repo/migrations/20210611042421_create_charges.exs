defmodule HubPayments.Repo.Migrations.CreateCharges do
  use Ecto.Migration

  def change do
    create table(:charges) do
      add :reference, :string
      add :request_date, :utc_datetime
      add :process_date, :utc_datetime
      add :settle_date, :utc_datetime
      add :money, :map, default: %{}
      add :uuid, :string
      add :owner, :map, default: %{}
      add :credit_card_id, references(:credit_cards, on_delete: :nothing)
      add :provider_id, references(:providers, on_delete: :nothing)

      timestamps()
    end

    create index(:charges, [:credit_card_id])
    create index(:charges, [:provider_id])
  end
end
