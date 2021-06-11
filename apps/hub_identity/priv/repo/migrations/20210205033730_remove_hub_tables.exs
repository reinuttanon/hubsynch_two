defmodule HubIdentity.Repo.Migrations.RemoveHubTables do
  use Ecto.Migration

  def change do
    drop table("addresses")
    drop table("telephones")
    drop table("hubsynch_v2_users")
  end
end
