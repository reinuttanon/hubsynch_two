defmodule HubIdentity.Repo.Migrations.AddNewFieldsToUserActivity do
  use Ecto.Migration

  def change do
    alter table("user_activities") do
      add :remote_address, :string
      add :user_agent, :string
    end
  end
end
