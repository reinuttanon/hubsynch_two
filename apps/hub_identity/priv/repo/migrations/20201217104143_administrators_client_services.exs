defmodule HubIdentity.Repo.Migrations.AdministratorsClientServices do
  use Ecto.Migration

  def change do
    create table(:administrators_client_services, primary_key: false) do
      add :administrator_id, references(:administrators)
      add :client_service_id, references(:client_services)
    end
  end
end
