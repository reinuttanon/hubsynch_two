defmodule HubIdentity.Repo.Migrations.AddEmailConfirmationRedirectUrl do
  use Ecto.Migration

  def change do
    alter table("client_services") do
      add :email_confirmation_redirect_url, :string
    end
  end
end
