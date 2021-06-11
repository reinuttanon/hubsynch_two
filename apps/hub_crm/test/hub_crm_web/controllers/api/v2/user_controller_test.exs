defmodule HubCrmWeb.Api.V2.UserControllerTest do
  use HubCrmWeb.ConnCase

  import HubCrm.Factory

  alias HubCrm.Identities
  alias HubCrm.Identities.User

  describe "create user" do
    test "renders user when data is valid" do
      conn = build_api_conn()

      response =
        post(conn, Routes.user_path(conn, :create), user: params_for(:user))
        |> json_response(201)

      assert response["data"]["first_name"] == "Capirca"
      assert response["data"]["first_name_kana"] == "カプリか"
      assert response["data"]["gender"] == "famale"
      assert response["data"]["last_name"] == "Six"
      assert response["data"]["last_name_kana"] == "シくス"
      assert response["data"]["occupation"] == "Cylon SuperStar!"
      refute response["data"]["uuid"] == nil
    end

    test "renders errors when data is invalid" do
      conn = build_api_conn()

      errors =
        post(conn, Routes.user_path(conn, :create), user: %{})
        |> json_response(400)

      assert errors == %{
               "error" => %{"first_name" => ["can't be blank"], "last_name" => ["can't be blank"]}
             }
    end
  end

  describe "update user" do
    test "renders user when data is valid" do
      conn = build_api_conn()
      user = insert(:user)

      response =
        put(conn, Routes.user_path(conn, :update, user.uuid),
          user: %{first_name: "Bonnie", last_name: "Boeger"}
        )
        |> json_response(200)

      assert response["data"]["first_name"] == "Bonnie"
      assert response["data"]["first_name_kana"] == user.first_name_kana
      assert response["data"]["gender"] == user.gender
      assert response["data"]["last_name"] == "Boeger"
      assert response["data"]["last_name_kana"] == user.last_name_kana
      assert response["data"]["occupation"] == user.occupation
      assert response["data"]["uuid"] == user.uuid
    end

    test "renders errors when data is invalid" do
      conn = build_api_conn()
      user = insert(:user)

      errors =
        put(conn, Routes.user_path(conn, :update, user.uuid),
          user: %{first_name: nil, last_name: nil}
        )
        |> json_response(400)

      assert errors == %{
               "error" => %{"first_name" => ["can't be blank"], "last_name" => ["can't be blank"]}
             }
    end
  end

  describe "delete user" do
    test "deletes chosen user" do
      user = insert(:user)
      conn = build_api_conn()

      response =
        delete(conn, Routes.user_path(conn, :delete, user.uuid))
        |> response(204)

      null =
        get(conn, Routes.user_path(conn, :show, user.uuid))
        |> response(200)

      assert null == "{\"data\":null}"
    end
  end

  defp build_api_conn do
    api_key = HubCrm.HubIdentityFactory.insert(:api_key)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
