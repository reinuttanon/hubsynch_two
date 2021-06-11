defmodule HubCrm.HubsynchRepo.Migrations.AddDeliveringAddresses do
  use Ecto.Migration

  def change do
    create table("delivering_addresses", primary_key: false) do
      add :user_address_id, :"int unsigned AUTO_INCREMENT", primary_key: true
      add :user_id, :integer
      add :delivering_address_last_name, :string
      add :delivering_address_first_name, :string
      add :delivering_address_last_name_kana, :string
      add :delivering_address_first_name_kana, :string
      add :delivering_address_last_name_rome, :string
      add :delivering_address_first_name_rome, :string
      add :last_name_rome, :string
      add :first_name_rome, :string
      add :zip_code, :string
      add :country, :integer
      add :address_1, :integer
      add :address_2, :string
      add :address_3, :string
      add :tel, :string
      add :default_flag, :string

      timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
    end
  end
end
