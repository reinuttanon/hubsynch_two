defmodule HubCrmWeb.Api.V2.AddressView do
  use HubCrmWeb, :view
  alias HubCrmWeb.Api.V2.AddressView

  def render("index.json", %{addresses: addresses}) do
    %{data: render_many(addresses, AddressView, "address.json")}
  end

  def render("show.json", %{address: address}) do
    %{data: render_one(address, AddressView, "address.json")}
  end

  def render("address.json", %{address: address}) do
    %{
      address_1: address.address_1,
      address_2: address.address_2,
      address_3: address.address_3,
      address_4: address.address_4,
      address_5: address.address_5,
      country: address.country,
      postal_code: address.postal_code,
      default: address.default,
      uuid: address.uuid
    }
  end
end
