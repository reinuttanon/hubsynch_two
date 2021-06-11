defmodule HubIdentity.Repo.Migrations.ModifyEmailConstraintWithTokens do
  use Ecto.Migration

  def change do
    drop constraint("users_tokens", "users_tokens_email_id_fkey")

    alter table(:users_tokens) do
      modify :email_id, references(:emails, on_delete: :delete_all)
    end
  end
end
