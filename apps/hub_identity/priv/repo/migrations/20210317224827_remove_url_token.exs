defmodule HubIdentity.Repo.Migrations.RemoveUrlToken do
  use Ecto.Migration

  def change do
    alter table("client_services") do
      remove :url_token
    end
  end
end
