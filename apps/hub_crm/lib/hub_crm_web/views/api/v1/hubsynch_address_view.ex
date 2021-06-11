defmodule HubCrmWeb.Api.V1.HubsynchAddressView do
  @moduledoc false
  use HubCrmWeb, :view

  import HubCrm.Hubsynch.FieldDefinitions, only: [get_value: 2, get_country: 1]

  alias HubCrmWeb.Api.V1.HubsynchAddressView

  def render("index.json", %{addresses: addresses}) do
    render_many(addresses, HubsynchAddressView, "address.json")
  end

  def render("show.json", %{address: address}) do
    render_one(address, HubsynchAddressView, "address.json")
  end

  def render("address.json", %{hubsynch_address: address}) do
    %{
      Object: "Address",
      id: address.id,
      address_1: get_value(:address_1, address.address_1),
      address_2: address.address_2,
      address_3: address.address_3,
      country: get_country(address.country),
      create_timestamp: address.create_timestamp,
      default_flag: address.default_flag,
      first_name: address.first_name,
      first_name_kana: address.first_name_kana,
      first_name_rome: address.first_name_rome,
      last_name: address.last_name,
      last_name_kana: address.last_name_kana,
      last_name_rome: address.last_name_rome,
      tel: address.tel,
      update_timestamp: address.update_timestamp,
      user_id: address.user_id,
      zip_code: address.zip_code
    }
  end
end
