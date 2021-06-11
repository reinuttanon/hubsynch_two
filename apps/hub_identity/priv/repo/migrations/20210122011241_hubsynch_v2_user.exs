defmodule HubIdentity.Repo.Migrations.HubsynchV2User do
  use Ecto.Migration

  def change do
    create table(:hubsynch_v2_users) do
      add :hubsynch_user_id, :string
      add :hash_id, :string
      add :first_name, :string
      add :last_name, :string
      add :first_name_roman, :string
      add :last_name_roman, :string
      add :birthdate, :date
      add :blood_type, :string
      add :gender, :string
      add :occupation, :string
      add :profile_image, :string
      add :uid, :string
      add :deleted_at, :utc_datetime
      timestamps()
    end

    create unique_index(:hubsynch_v2_users, [:uid])
  end
end
