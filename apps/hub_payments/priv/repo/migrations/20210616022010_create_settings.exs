defmodule HubPayments.Repo.Migrations.CreateSettings do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :key, :string
      add :value, :string
      add :description, :string
      add :active, :boolean, default: true, null: false
      add :type, :string
      add :env, :string

      timestamps()
    end

  end
end
