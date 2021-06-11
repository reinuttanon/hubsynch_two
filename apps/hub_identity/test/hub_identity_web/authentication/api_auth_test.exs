defmodule HubIdentityWeb.Authentication.ApiAuthTest do
  use HubIdentityWeb.ConnCase, async: true

  import HubIdentity.Factory

  describe "authentication" do
    setup [:create_email]

    test "with proper x-api-key header returns a session", %{email: email} do
      client_service = insert(:client_service)
      api_key = insert(:api_key, type: "public", client_service: client_service)

      conn =
        build_api_conn(api_key.data)
        |> post("/api/v1/providers/hub_identity", %{
          "email" => email.address,
          "password" => "password"
        })

      assert get_session(conn, :client_service) == client_service
      assert get_session(conn, :api_permission) == "public"
    end

    test "without x-api-key header returns 401 not authorized", %{email: email} do
      conn =
        build_conn()
        |> post("/api/v1/providers/hub_identity", %{
          "email" => email.address,
          "password" => "password"
        })

      assert response(conn, 401) =~ "not authorized"
    end

    test "with bad x-api-key returns 401 not authorized", %{email: email} do
      client_service = insert(:client_service)
      insert(:api_key, type: "public", client_service: client_service)

      conn =
        build_api_conn("bad_key")
        |> post("/api/v1/providers/hub_identity", %{
          "email" => email.address,
          "password" => "password"
        })

      assert response(conn, 401) =~ "not authorized"
    end
  end

  defp build_api_conn(api_key) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key)
  end

  defp create_email(_) do
    email = insert(:email)
    %{email: email}
  end
end
