defmodule HubIdentity.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :address, :string
      add :confirmed_at, :utc_datetime
      add :primary, :boolean, default: false, null: false
      add :uid, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:emails, [:user_id])
  end
end
