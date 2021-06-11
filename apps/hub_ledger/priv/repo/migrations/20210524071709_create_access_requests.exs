defmodule HubLedger.Repo.Migrations.CreateAccessRequests do
  use Ecto.Migration

  def change do
    create table(:access_requests) do
      add :approved_at, :utc_datetime
      add :hub_identity_uid, :string
      add :approver_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:access_requests, [:approver_id])
  end
end
