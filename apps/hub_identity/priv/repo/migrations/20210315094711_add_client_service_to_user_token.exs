defmodule HubIdentity.Repo.Migrations.AddClientServiceToUserToken do
  use Ecto.Migration

  def change do
    alter table("users_tokens") do
      add :client_service_id, references(:client_services, on_delete: :nothing)
    end

    create index(:users_tokens, [:client_service_id])
  end
end
