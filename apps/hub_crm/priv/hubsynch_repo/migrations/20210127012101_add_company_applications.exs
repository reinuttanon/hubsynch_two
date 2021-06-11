defmodule HubCrm.HubsynchRepo.Migrations.AddCompanyApplications do
  use Ecto.Migration

  def change do
    create table("company_applications", primary_key: false) do
      add :company_app_id, :"int unsigned AUTO_INCREMENT", primary_key: true
      add :company_id, :integer
      add :app_code, :string
      add :site_id, :string
      add :site_name, :string
      add :site_icon_url, :string
      add :restful_url_product, :string
      add :restful_url_transport, :string
      add :restful_url_orderstart, :string
      add :restful_url_payment_complete, :string
      add :restful_url_item_purchase_complete, :string
      add :restful_url_subsceription_payment_complete, :string
      add :restful_url_account_migrate_endpoint, :string
      add :restful_url_user_register_complete, :string
      add :restful_url_user_mail_check, :string
      add :restful_url_user_update_complete, :string
      add :restful_url_refund, :string
      add :carrier_payment_success_url, :string
      add :carrier_payment_error_url, :string
      add :carrier_payment_cancel_url, :string
      add :product_list_url, :string
      add :purchase_genre_code, :integer
      add :user_information_update_section, :integer
      add :use_company_flag, :string
      add :managed_payament_gateway_only_use_flag, :string
      add :payment_mail_flag, :string
      add :api_key, :string
      add :api_secret, :string
      add :offline_access_token, :string
      add :use_cash_on_delivery, :string
      add :ticket_secret_key, :string
      add :ticket_api_key, :string
      add :delete_flag, :string
      add :age_limit, :integer

      timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
    end
  end
end
