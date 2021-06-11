defmodule HubIdentity.Repo.Migrations.CreateUsersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :confirmed_at, :naive_datetime
      add :deleted_at, :utc_datetime
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :owner_type, :string
      add :owner_uid, :string
      add :uid, :string
      add :client_service_id, references(:client_services, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:users, [:email, :client_service_id])
    create unique_index(:users, [:uid])
    create index(:users, [:client_service_id])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
