defmodule HubCrm.Hubsynch.CompanyApplication do
  @moduledoc false
  use Ecto.Schema
  # import Ecto.Changeset

  @primary_key {:company_app_id, :id, autogenerate: true}

  schema "company_applications" do
    field :company_id, :integer
    field :app_code, :string
    field :site_id, :string
    field :site_name, :string
    field :site_icon_url, :string
    field :restful_url_product, :string
    field :restful_url_transport, :string
    field :restful_url_orderstart, :string
    field :restful_url_payment_complete, :string
    field :restful_url_item_purchase_complete, :string
    field :restful_url_subsceription_payment_complete, :string
    field :restful_url_account_migrate_endpoint, :string
    field :restful_url_user_register_complete, :string
    field :restful_url_user_mail_check, :string
    field :restful_url_user_update_complete, :string
    field :restful_url_refund, :string
    field :carrier_payment_success_url, :string
    field :carrier_payment_error_url, :string
    field :carrier_payment_cancel_url, :string
    field :product_list_url, :string
    field :purchase_genre_code, :integer
    field :user_information_update_section, :integer
    field :use_company_flag, :string
    field :managed_payament_gateway_only_use_flag, :string
    field :payment_mail_flag, :string
    field :api_key, :string
    field :api_secret, :string
    field :offline_access_token, :string
    field :use_cash_on_delivery, :string
    field :ticket_secret_key, :string
    field :ticket_api_key, :string
    field :delete_flag, :string
    field :age_limit, :integer

    timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
  end
end
