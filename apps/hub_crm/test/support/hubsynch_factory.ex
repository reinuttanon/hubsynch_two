defmodule HubCrm.HubsynchFactory do
  # with Ecto
  use ExMachina.Ecto, repo: HubCrm.HubsynchRepo

  alias HubCrm.Hubsynch.{CompanyApplication, DeliveringAddress, User, UseApp}

  def company_application_factory do
    %CompanyApplication{
      app_code: "app_code",
      site_id: "site_id",
      site_name: "site_name",
      site_icon_url: "site_icon_url",
      restful_url_product: "restful_url_product",
      restful_url_transport: "restful_url_transport",
      restful_url_orderstart: "restful_url_orderstart",
      restful_url_payment_complete: "restful_url_payment_complete",
      restful_url_item_purchase_complete: "restful_url_item_purchase_complete",
      restful_url_subsceription_payment_complete: "restful_url_subsceription_payment_complete",
      restful_url_account_migrate_endpoint: "restful_url_account_migrate_endpoint",
      restful_url_user_register_complete: "restful_url_user_register_complete",
      restful_url_user_mail_check: "restful_url_user_mail_check",
      restful_url_user_update_complete: "restful_url_user_update_complete",
      restful_url_refund: "restful_url_refund",
      carrier_payment_success_url: "carrier_payment_success_url",
      carrier_payment_error_url: "carrier_payment_error_url",
      carrier_payment_cancel_url: "carrier_payment_cancel_url",
      product_list_url: "product_list_url",
      purchase_genre_code: 1,
      user_information_update_section: 1,
      use_company_flag: "use_company_flag",
      managed_payament_gateway_only_use_flag: "managed_payament_gateway_only_use_flag",
      payment_mail_flag: "payment_mail_flag",
      api_key: "api_key",
      api_secret: "api_secret",
      offline_access_token: "offline_access_token",
      use_cash_on_delivery: "use_cash_on_delivery",
      ticket_secret_key: "ticket_secret_key",
      ticket_api_key: "ticket_api_key",
      delete_flag: "false",
      age_limit: 1
    }
  end

  def delivering_address_factory do
    %DeliveringAddress{
      user_address_id: sequence(:user_address_id, &(&1 + 10)),
      address_1: 1,
      address_2: "address_2",
      address_3: "address_3",
      country: 1,
      default_flag: "true",
      delivering_address_last_name: "delivering_address_last_name",
      delivering_address_first_name: "delivering_address_first_name",
      delivering_address_last_name_kana: "delivering_address_last_name_kana",
      delivering_address_first_name_kana: "delivering_address_first_name_kana",
      delivering_address_last_name_rome: "delivering_address_last_name_rome",
      delivering_address_first_name_rome: "delivering_address_first_name_rome",
      tel: "telephone",
      user_id: sequence(:user_id, &(&1 * Enum.random(1..100))),
      zip_code: "1234567"
    }
  end

  def user_factory do
    %User{
      user_id: sequence(:user_id, &(&1 + 1)),
      address_1: 2,
      address_2: "Chome−21−20",
      address_3: "霞町コーポ B1F",
      birthday: Date.utc_today(),
      blood: 1,
      country: 1,
      email: sequence(:email, &"erin-#{&1}@hivelocity.co.jp.co"),
      first_name: "erin",
      first_name_kana: "",
      hashid: "2NP7-m50b-inY4-3x1B",
      last_name: "boeger",
      last_name_kana: "",
      occupation: 1,
      password: "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8",
      sex: 1,
      tel: "03-6447-5610",
      zip_code: "1060032",
      company_app_id: 1
    }
  end

  def use_app_factory do
    %UseApp{
      company_app_id: 1,
      company_id: 1,
      user_id: 1,
      guest_id: 1,
      developer_purchase_user_id: 1,
      delete_flag: "false"
    }
  end
end
