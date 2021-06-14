defmodule HubCrmWeb.Plugs.ApiAuthTest do
  use HubCrmWeb.ConnCase, async: true

  describe "authentication" do
    setup [:create_user]

    test "with proper x-api-key header returns a session", %{user: user} do
      api_key = HubIdentity.Factory.insert(:api_key, type: "private")

      conn =
        build_api_conn(api_key.data)
        |> get("/api/v2/users/#{user.id}")

      assert get_session(conn, :api_key) == api_key
    end

    test "without x-api-key header returns 401 not authorized", %{user: user} do
      conn =
        build_conn()
        |> get("/api/v2/users/#{user.id}")

      assert response(conn, 401) =~ "not authorized"
    end

    test "with public x-api-key returns 401 not authorized", %{user: user} do
      api_key = HubIdentity.Factory.insert(:api_key, type: "public")

      conn =
        build_api_conn(api_key.data)
        |> get("/api/v2/users/#{user.id}")

      assert response(conn, 401) =~ "not authorized"
    end

    test "with fake x-api-key returns 401 not authorized", %{user: user} do
      conn =
        build_api_conn("bad_key_123456")
        |> get("/api/v2/users/#{user.id}")

      assert response(conn, 401) =~ "not authorized"
    end
  end

  defp create_user(_) do
    user = insert(:user)
    %{user: user}
  end

  defp build_api_conn(api_key) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key)
  end
end
