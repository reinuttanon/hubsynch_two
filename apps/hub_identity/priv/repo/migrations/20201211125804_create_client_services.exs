defmodule HubIdentity.Repo.Migrations.CreateClientServices do
  use Ecto.Migration

  def change do
    create table(:client_services) do
      add :deleted_at, :utc_datetime
      add :description, :text
      add :name, :string
      add :redirect_url, :string
      add :uid, :string
      add :url, :string
      add :webhook_auth_key, :string
      add :webhook_auth_type, :string
      add :webhook_url, :string

      timestamps()
    end
  end
end
