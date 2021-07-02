defmodule HubPayments.Repo.Migrations.CreatePaymentConfigs do
  use Ecto.Migration

  def change do
    create table(:payment_configs) do
      add :client_service_uuid, :string
      add :deleted_at, :utc_datetime
      add :payment_methods, {:array, :string}
      add :statement_name, :string
      add :uuid, :string
      add :provider_id, references(:providers, on_delete: :nothing)

      timestamps()
    end

    create index(:payment_configs, [:provider_id])
  end
end
