defmodule HubIdentity.Repo.Migrations.CreateOauthUsers do
  use Ecto.Migration

  def change do
    create table(:oauth_users) do
      add :deleted_at, :utc_datetime
      add :details, :map
      add :email, :string
      add :owner_uid, :string
      add :owner_type, :string
      add :provider, :string
      add :provider_id, :string
      add :uid, :string
      add :client_service_id, references(:client_services, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:oauth_users, [:uid])
    create unique_index(:oauth_users, [:provider, :provider_id, :client_service_id])
    create index(:oauth_users, [:client_service_id])
  end
end
