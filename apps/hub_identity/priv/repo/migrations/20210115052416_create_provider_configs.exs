defmodule HubIdentity.Repo.Migrations.CreateProviderConfigs do
  use Ecto.Migration

  def change do
    create table(:provider_configs) do
      add :name, :string
      add :client_id, :string
      add :client_secret, :string
      add :scopes, :string
      add :uid, :string
      add :auth_url, :string
      add :access_token_url, :string
      add :active, :boolean
      add :deleted_at, :utc_datetime

      timestamps()
    end
  end
end
