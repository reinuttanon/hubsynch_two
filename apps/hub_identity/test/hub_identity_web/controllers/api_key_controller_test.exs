defmodule HubIdentityWeb.ApiKeyControllerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  setup :register_and_log_in_administrator

  describe "create api_key" do
    test "redirects to show when data is valid", %{conn: conn} do
      client_service = insert(:client_service)

      conn =
        post(conn, Routes.api_key_path(conn, :create),
          api_key: %{client_service_id: client_service.id, type: "public"}
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.api_key_path(conn, :show, id)

      conn = get(conn, Routes.api_key_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Api key"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.api_key_path(conn, :create), api_key: %{client_service_id: nil})
      assert html_response(conn, 200) =~ "New Api key"
    end
  end

  describe "delete api_key" do
    setup [:create_api_key]

    test "deletes chosen api_key", %{conn: conn, api_key: api_key} do
      conn = delete(conn, Routes.api_key_path(conn, :delete, api_key))
      assert redirected_to(conn) == Routes.api_key_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_key_path(conn, :show, api_key))
      end
    end
  end

  defp create_api_key(_) do
    api_key = insert(:api_key)
    %{api_key: api_key}
  end
end
