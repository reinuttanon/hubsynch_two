defmodule HubPayments.Repo.Migrations.CreateAtmPayment do
  use Ecto.Migration

  def change do
    create table(:atm_payments) do
      add :uuid, :string
      add :owner, :map, default: %{}
      add :money, :map, default: %{}
      add :reference, :string
      add :request_date, :utc_datetime
      add :process_date, :utc_datetime
      add :payment_detail, :string
      add :payment_detail_kana, :string
      add :payment_limit_date, :integer
      add :provider_id, references(:providers, on_delete: :nothing)

      timestamps()
    end

    create index(:atm_payments, [:provider_id])
  end
end
