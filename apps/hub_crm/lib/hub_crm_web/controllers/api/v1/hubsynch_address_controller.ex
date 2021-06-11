defmodule HubCrmWeb.Api.V1.HubsynchAddressController do
  @moduledoc false
  use HubCrmWeb, :api_controller

  alias HubCrm.Hubsynch
  alias HubCrm.Hubsynch.{Address, User}

  # action_fallback HubCrmWeb.Api.V1.FallbackController

  def index(conn, %{"user_id" => user_id}) do
    with addresses when is_list(addresses) <- Hubsynch.get_addresses(user_id) do
      render(conn, "index.json", addresses: addresses)
    end
  end

  def create(conn, %{"user_id" => user_id, "address" => address_params}) do
    with %User{} = user <- Hubsynch.get_user(user_id),
         {:ok, %Address{} = address} <- Hubsynch.create_address(user, address_params) do
      conn
      |> put_status(:created)
      |> render("show.json", address: address)
    end
  end

  def show(conn, %{"user_id" => user_id, "address_id" => address_id}) do
    with %Address{} = address <- Hubsynch.get_address(user_id, address_id) do
      render(conn, "show.json", address: address)
    end
  end

  def update(conn, %{
        "user_id" => user_id,
        "address_id" => address_id,
        "address" => address_params
      }) do
    with {:ok, %Address{} = address} <-
           Hubsynch.update_address(user_id, address_id, address_params) do
      render(conn, "show.json", address: address)
    end
  end
end
