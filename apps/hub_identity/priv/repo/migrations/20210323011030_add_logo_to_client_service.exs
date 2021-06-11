defmodule HubIdentity.Repo.Migrations.AddLogoToClientService do
  use Ecto.Migration

  def change do
    alter table("client_services") do
      add :logo, :string
    end
  end
end
