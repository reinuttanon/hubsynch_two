defmodule HubCrm.HubsynchRepo.Migrations.AddUseApps do
  use Ecto.Migration

  def change do
    create table("use_apps", primary_key: false) do
      add :use_app_id, :"int unsigned AUTO_INCREMENT", primary_key: true
      add :company_app_id, :integer
      add :company_id, :integer
      add :user_id, :integer
      add :guest_id, :integer
      add :developer_purchase_user_id, :integer
      add :delete_flag, :string, default: "false"
      timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
    end
  end
end
