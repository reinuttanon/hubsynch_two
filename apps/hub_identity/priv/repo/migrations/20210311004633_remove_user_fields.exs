defmodule HubIdentity.Repo.Migrations.RemoveUserFields do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove :confirmed_at
      remove :email
      remove :client_service_id
      remove :owner_uid
      remove :owner_type
    end
  end
end
