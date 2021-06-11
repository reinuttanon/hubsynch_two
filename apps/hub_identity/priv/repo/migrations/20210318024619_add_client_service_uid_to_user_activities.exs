defmodule HubIdentity.Repo.Migrations.AddClientServiceUidToUserActivities do
  use Ecto.Migration

  def change do
    alter table("user_activities") do
      add :client_service_uid, :string
    end
  end
end
