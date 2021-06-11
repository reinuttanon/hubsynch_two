defmodule HubIdentity.Repo.Migrations.DropOauthUsersAndDataDeletions do
  use Ecto.Migration

  def change do
    drop table("oauth_users")
    drop table("data_deletions")
  end
end
