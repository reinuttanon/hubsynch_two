defmodule HubIdentity.Repo.Migrations.RemoveClientServiceIdUserActivitiesColumn do
  use Ecto.Migration

  def change do
    alter table("user_activities") do
      remove :client_service_id
    end
  end
end
