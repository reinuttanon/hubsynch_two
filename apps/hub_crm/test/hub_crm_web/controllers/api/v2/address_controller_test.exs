defmodule HubCrmWeb.Api.V2.AddressControllerTest do
  use HubCrmWeb.ConnCase

  import HubCrm.Factory

  describe "index" do
    test "lists all addresses" do
      conn = build_api_conn()
      user = insert(:user)
      insert(:address, user: user)
      insert(:address, user: user)

      response =
        get(conn, Routes.address_path(conn, :index, user.uuid))
        |> json_response(200)

      assert length(response["data"]) == 2
    end
  end

  describe "create address" do
    test "renders address when data is valid" do
      conn = build_api_conn()
      user = insert(:user)

      response =
        post(conn, Routes.address_path(conn, :create, user.uuid), %{address: params_for(:address)})
        |> json_response(201)

      assert response["data"]["address_1"] == "3-7-27 51Fl"
      assert response["data"]["address_2"] == "Hiyoshi"
      assert response["data"]["address_3"] == "Kohoku Ku"
      assert response["data"]["address_4"] == "Yokohama Shi"
      assert response["data"]["address_5"] == "Kanagawa Ken"
      assert response["data"]["country"] == "JPN"
      assert response["data"]["uuid"] != nil
    end

    test "renders errors when data is invalid" do
      conn = build_api_conn()
      user = insert(:user)

      errors =
        post(conn, Routes.address_path(conn, :create, user.uuid),
          address: %{country: nil, postal_code: nil}
        )
        |> json_response(400)

      assert errors == %{
               "error" => %{"country" => ["can't be blank"], "postal_code" => ["can't be blank"]}
             }
    end
  end

  describe "update address" do
    test "renders address when data is valid" do
      conn = build_api_conn()
      user = insert(:user)
      address = insert(:address, user: user)

      response =
        put(conn, Routes.address_path(conn, :update, user.uuid, address.uuid),
          address: %{address_1: "1-1-1 111Fl", address_2: "Roppongi"}
        )
        |> json_response(200)

      assert response["data"]["address_1"] == "1-1-1 111Fl"
      assert response["data"]["address_2"] == "Roppongi"
      assert response["data"]["country"] == address.country
      assert response["data"]["uuid"] == address.uuid
    end

    test "renders errors when data is invalid" do
      conn = build_api_conn()
      user = insert(:user)
      address = insert(:address, user: user)

      errors =
        put(conn, Routes.address_path(conn, :update, user.uuid, address.uuid),
          address: %{country: nil, postal_code: nil}
        )
        |> json_response(400)

      assert errors == %{
               "error" => %{"country" => ["can't be blank"], "postal_code" => ["can't be blank"]}
             }
    end
  end

  describe "delete address" do
    test "deletes chosen address" do
      conn = build_api_conn()
      user = insert(:user)
      address = insert(:address, user: user)

      delete(conn, Routes.address_path(conn, :delete, user.uuid, address.uuid))
      |> response(204)

      null =
        get(conn, Routes.address_path(conn, :show, user.uuid, address.uuid))
        |> response(200)

      assert null == "{\"data\":null}"
    end
  end

  defp build_api_conn do
    api_key = HubIdentity.Factory.insert(:api_key, type: "private")

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
