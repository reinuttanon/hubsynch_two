defmodule HubCrm.HubsynchRepo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table("users", primary_key: false) do
      add :user_id, :"int unsigned AUTO_INCREMENT", primary_key: true
      add :hashid, :string
      add :restore_code, :string
      add :email, :string
      add :password, :string
      add :last_name, :string
      add :first_name, :string
      add :last_name_kana, :string
      add :first_name_kana, :string
      add :last_name_rome, :string
      add :first_name_rome, :string
      add :birthday, :date
      add :blood, :integer
      add :sex, :integer
      add :occupation, :integer
      add :country, :integer
      add :zip_code, :string
      add :address_1, :integer
      add :address_2, :string
      add :address_3, :string
      add :tel, :string
      add :profile_image, :string
      add :activate_code, :string
      add :auth_code, :string
      add :auth_code_expired_datetime, :naive_datetime
      add :activate_code_expire_timestamp, :naive_datetime
      add :activate_flag, :string
      add :delete_flag, :string
      add :restore_code_expired_datetime, :naive_datetime

      timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
    end
  end
end
