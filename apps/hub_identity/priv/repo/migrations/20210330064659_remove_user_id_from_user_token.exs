defmodule HubIdentity.Repo.Migrations.RemoveUserIdFromUserToken do
  use Ecto.Migration

  def change do
    alter table("users_tokens") do
      remove :user_id
    end
  end
end
