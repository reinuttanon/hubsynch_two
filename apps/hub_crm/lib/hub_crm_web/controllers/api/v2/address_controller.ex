defmodule HubCrmWeb.Api.V2.AddressController do
  use HubCrmWeb, :api_controller

  alias HubCrm.Identities
  alias HubCrm.Identities.{Address, User}

  def index(conn, %{"user_uuid" => user_uuid}) do
    with %User{id: id} <- Identities.get_user(%{uuid: user_uuid}),
         addresses <- Identities.list_addresses(%{user_id: id}) do
      render(conn, "index.json", addresses: addresses)
    end
  end

  def create(conn, %{"user_uuid" => user_uuid, "address" => address_params}) do
    with %User{id: id} <- Identities.get_user(%{uuid: user_uuid}),
         {:ok, %Address{} = address} <-
           Identities.create_address(Map.put(address_params, "user_id", id)) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.address_path(conn, :show, user_uuid, address.uuid))
      |> render("show.json", address: address)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    address = Identities.get_address(%{uuid: uuid})
    render(conn, "show.json", address: address)
  end

  def update(conn, %{"uuid" => uuid, "address" => address_params}) do
    address = Identities.get_address(%{uuid: uuid})

    with {:ok, %Address{} = address} <- Identities.update_address(address, address_params) do
      render(conn, "show.json", address: address)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    address = Identities.get_address(%{uuid: uuid})

    with {:ok, %Address{}} <- Identities.delete_address(address) do
      send_resp(conn, :no_content, "")
    end
  end
end
