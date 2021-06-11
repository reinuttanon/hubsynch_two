defmodule HubIdentity.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:identities) do
      add :details, :map
      add :uid, :string
      add :reference, :string
      add :provider_config_id, references(:provider_configs, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:identities, [:provider_config_id])
    create index(:identities, [:user_id])
  end
end
