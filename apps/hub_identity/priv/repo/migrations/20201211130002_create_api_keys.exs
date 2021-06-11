defmodule HubIdentity.Repo.Migrations.CreateApiKeys do
  use Ecto.Migration

  def change do
    create table(:api_keys) do
      add :data, :string
      add :deleted_at, :utc_datetime
      add :type, :string
      add :uid, :string
      add :client_service_id, references(:client_services, on_delete: :nothing)

      timestamps()
    end

    create index(:api_keys, [:client_service_id])
  end
end
