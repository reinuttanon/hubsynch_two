defmodule HubIdentity.Repo.Migrations.AddUserIdAllowNilToUserToken do
  use Ecto.Migration

  def change do
    alter table("users_tokens") do
      add :user_id, references(:users, on_delete: :delete_all), null: true
    end

    create index(:users_tokens, [:user_id])
  end
end
