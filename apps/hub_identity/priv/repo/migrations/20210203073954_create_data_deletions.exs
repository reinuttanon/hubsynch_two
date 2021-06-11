defmodule HubIdentity.Repo.Migrations.CreateDataDeletions do
  use Ecto.Migration

  def change do
    create table(:data_deletions) do
      add :oauth_user_uids, {:array, :string}
      add :provider, :string
      add :uid, :string

      timestamps()
    end
  end
end
