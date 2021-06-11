defmodule HubIdentity.Repo.Migrations.AlterTokenToEmail do
  use Ecto.Migration

  def change do
    alter table("users_tokens") do
      add :email_id, references(:emails, on_delete: :nothing)
    end

    create index(:users_tokens, [:email_id])
  end
end
