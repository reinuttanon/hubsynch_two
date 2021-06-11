defmodule HubIdentity.Repo.Migrations.RemoveEmailFromUserToken do
  use Ecto.Migration

  def change do
    alter table("users_tokens") do
      remove :email_id
    end
  end
end
