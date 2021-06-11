defmodule HubCrmWeb.Api.V1.HubsynchAddressControllerTest do
  use HubCrmWeb.ConnCase

  alias HubCrm.HubsynchFactory

  describe "index/2" do
    test "returns all a users addresses" do
      user = HubsynchFactory.insert(:user)

      for _ <- 1..3 do
        HubsynchFactory.insert(:delivering_address, %{user_id: user.user_id})
      end

      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.user_id}/addresses")
        |> json_response(200)

      assert 4 == length(response)

      for address <- response do
        assert address["Object"] == "Address"
        assert address["user_id"] == user.user_id
      end
    end

    test "returns only the user record if no delivering_addresses" do
      user = HubsynchFactory.insert(:user)

      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.user_id}/addresses")
        |> json_response(200)

      assert 1 == length(response)
    end
  end

  describe "create/2" do
    test "returns an address with valid params" do
      user = HubsynchFactory.insert(:user)
      address_params = HubsynchFactory.params_for(:delivering_address)

      response =
        build_api_conn()
        |> post("/api/v1/users/#{user.user_id}/addresses", address: address_params)
        |> json_response(201)

      assert response["Object"] == "Address"
      assert response["user_id"] == user.user_id
      refute response["id"] == nil
    end

    test "returns a errors with invalid params" do
      user = HubsynchFactory.insert(:user)

      response =
        build_api_conn()
        |> post("/api/v1/users/#{user.user_id}/addresses", address: %{country: nil, zip_code: nil})
        |> json_response(400)

      assert response["error"]["country"] == ["can't be blank"]
      assert response["error"]["zip_code"] == ["can't be blank"]
    end

    test "returns error with invalid user" do
      address_params = HubsynchFactory.params_for(:delivering_address)

      error =
        build_api_conn()
        |> post("/api/v1/users/555/addresses", address: address_params)

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "show/2" do
    test "returns the delivering_address with a valid id" do
      user = HubsynchFactory.insert(:user)
      address_1 = HubsynchFactory.insert(:delivering_address, %{user_id: user.user_id})
      address_2 = HubsynchFactory.insert(:delivering_address, %{user_id: user.user_id})

      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.user_id}/addresses/#{address_1.user_address_id}")
        |> json_response(200)

      assert response["Object"] == "Address"
      assert response["user_id"] == user.user_id
      assert response["id"] == address_1.user_address_id
      refute response["id"] == address_2.user_address_id
    end

    test "returns error if bad user_id or bad address_id" do
      user = HubsynchFactory.insert(:user)
      user_2 = HubsynchFactory.insert(:user)
      address = HubsynchFactory.insert(:delivering_address, %{user_id: user.user_id})

      error =
        build_api_conn()
        |> get("/api/v1/users/#{user.user_id}/addresses/555")

      assert response(error, 400) =~ "bad request"

      error =
        build_api_conn()
        |> get("/api/v1/users/#{user_2.user_id}/addresses/#{address.user_address_id}")

      assert response(error, 400) =~ "bad request"

      error =
        build_api_conn()
        |> get("/api/v1/users/555/addresses/#{address.user_address_id}")

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "update/2" do
    test "returns an updated address with valid params" do
      address = HubsynchFactory.insert(:delivering_address)
      params = %{address_1: 15, address_2: "soi 15 braditmanuthamn"}

      response =
        build_api_conn()
        |> put("/api/v1/users/#{address.user_id}/addresses/#{address.user_address_id}",
          address: params
        )
        |> json_response(200)

      assert response["Object"] == "Address"
      assert response["id"] == address.user_address_id
      assert response["address_1"] == "新潟県"
      assert response["address_2"] == "soi 15 braditmanuthamn"
    end

    test "returns errors with invalid params" do
      address = HubsynchFactory.insert(:delivering_address)

      response =
        build_api_conn()
        |> put("/api/v1/users/#{address.user_id}/addresses/#{address.user_address_id}",
          address: %{country: nil, zip_code: nil}
        )
        |> json_response(400)

      assert response["error"]["country"] == ["can't be blank"]
      assert response["error"]["zip_code"] == ["can't be blank"]
    end

    test "returns error with invalid user or invalid address" do
      address = HubsynchFactory.insert(:delivering_address)

      error =
        build_api_conn()
        |> put("/api/v1/users/555/addresses/#{address.user_address_id}",
          address: %{country: 2, zip_code: "1234"}
        )

      assert response(error, 400) =~ "bad request"

      error =
        build_api_conn()
        |> put("/api/v1/users/#{address.user_id}/addresses/555",
          address: %{country: 2, zip_code: "1234"}
        )

      assert response(error, 400) =~ "bad request"
    end
  end

  defp build_api_conn do
    api_key = HubCrm.HubIdentityFactory.insert(:api_key)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
