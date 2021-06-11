defmodule HubCrmWeb.Api.V1.HubsynchUsersControllerTest do
  use HubCrmWeb.ConnCase, async: true

  describe "create/2" do
    test "creates a new user with valid params" do
      response =
        build_api_conn()
        |> post("/api/v1/users", %{
          user: %{
            email: "erinp+1@hivelocity.co.jp",
            first_name: "Erin",
            last_name: "Boeger"
          }
        })
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["email"] == "erinp+1@hivelocity.co.jp"
      assert response["hashid"] != nil
    end

    test "with invalid params returns bad request response with errors" do
      response =
        build_api_conn()
        |> post("/api/v1/users", %{
          user: %{
            email: "erinp+1@hivelocity.co.jp",
            blood: "10"
          }
        })
        |> json_response(400)

      assert response["error"]["blood"] == ["is invalid"]
    end
  end

  describe "show/2" do
    setup [:create_user]

    test "returns the found user by user_id", %{user: user} do
      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.user_id}")
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["email"] == user.email
      assert length(response["addresses"]) > 0
    end

    test "returns the found user by email", %{user: user} do
      response =
        build_api_conn()
        |> get("/api/v1/users?email=#{user.email}")
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["email"] == user.email
      assert length(response["addresses"]) > 0
    end

    test "returns bad request if no user" do
      error =
        build_api_conn()
        |> get("/api/v1/users/555")
        |> response(400)

      assert error == "bad request"
    end
  end

  describe "update/2" do
    setup [:create_user]

    test "returns the user updated", %{user: user} do
      assert user.first_name == "erin"

      response =
        build_api_conn()
        |> put("/api/v1/users/#{user.user_id}", user: %{first_name: "tiberious"})
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["first_name"] == "tiberious"
    end

    test "returns errors from invalid data", %{user: user} do
      response =
        build_api_conn()
        |> put("/api/v1/users/#{user.user_id}", user: %{blood: "b", sex: 4})
        |> json_response(400)

      assert response["error"]["sex"] == ["is invalid"]
      assert response["error"]["blood"] == ["is invalid"]
    end
  end

  describe "delete/2" do
    setup [:create_user]

    test "returns 204 success with a valid user", %{user: user} do
      message =
        build_api_conn()
        |> delete("/api/v1/users/#{user.user_id}")
        |> response(202)

      assert message =~ "successful operation"
    end

    test "returns bad request if no user" do
      error =
        build_api_conn()
        |> delete("/api/v1/users/555")
        |> response(400)

      assert error == "bad request"
    end
  end

  defp build_api_conn do
    api_key = HubCrm.HubIdentityFactory.insert(:api_key)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end

  defp create_user(_) do
    user = HubCrm.HubsynchFactory.insert(:user)
    HubCrm.HubsynchFactory.insert(:delivering_address, %{user_id: user.user_id})

    %{user: user}
  end
end
