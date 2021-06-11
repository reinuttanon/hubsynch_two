defmodule HubIdentity.Repo.Migrations.CreateUserActivities do
  use Ecto.Migration

  def change do
    create table(:user_activities) do
      add :owner_uid, :string
      add :owner_type, :string
      add :provider, :string
      add :type, :string
      add :uid, :string
      add :client_service_id, references(:client_services, on_delete: :nothing)

      timestamps()
    end

    create index(:user_activities, [:client_service_id])
  end
end
