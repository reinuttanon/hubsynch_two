defmodule HubIdentity.Repo.Migrations.AddPassChangeRedirectUrlToClientServices do
  use Ecto.Migration

  def change do
    alter table("client_services") do
      add :pass_change_redirect_url, :string
    end
  end
end
