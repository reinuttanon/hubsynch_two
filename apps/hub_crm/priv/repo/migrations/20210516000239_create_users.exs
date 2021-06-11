defmodule HubCrm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :first_name_kana, :string
      add :first_name_roman, :string
      add :last_name, :string
      add :last_name_kana, :string
      add :last_name_roman, :string
      add :gender, :string
      add :occupation, :string
      add :hub_identity_uid, :string
      add :uuid, :string

      timestamps()
    end

  end
end
