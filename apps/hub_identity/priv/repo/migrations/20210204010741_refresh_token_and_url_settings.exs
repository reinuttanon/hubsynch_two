defmodule HubIdentity.Repo.Migrations.RefreshTokenAndUrlSettings do
  use Ecto.Migration

  def change do
    alter table("client_services") do
      add :refresh_token, :boolean, default: true
      add :url_token, :boolean, default: false
    end
  end
end
