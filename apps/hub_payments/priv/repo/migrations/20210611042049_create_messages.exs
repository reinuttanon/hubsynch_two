defmodule HubPayments.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :type, :string
      add :owner, :map, default: %{}
      add :request, :string
      add :response, :string
      add :data, :map, default: %{}
      add :provider_id, references(:providers, on_delete: :nothing)

      timestamps()
    end

    create index(:messages, [:provider_id])
  end
end
