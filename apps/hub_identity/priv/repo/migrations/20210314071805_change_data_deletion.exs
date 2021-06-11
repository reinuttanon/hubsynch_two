defmodule HubIdentity.Repo.Migrations.ChangeDataDeletion do
  use Ecto.Migration

  def change do
    alter table("data_deletions") do
      add :identity_uid, :string
      remove :oauth_user_uids
    end
  end
end
