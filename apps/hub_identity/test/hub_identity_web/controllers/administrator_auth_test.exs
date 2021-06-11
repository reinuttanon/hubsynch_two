defmodule HubIdentityWeb.Plugs.AdministratorAuthTest do
  use HubIdentityWeb.ConnCase

  alias HubIdentity.Administration
  alias HubIdentityWeb.Authentication.AdministratorAuth
  import HubIdentity.AdministrationFixtures

  @remember_me_cookie "_hub_identity_web_administrator_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, HubIdentityWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{administrator: administrator_fixture(), conn: conn}
  end

  describe "log_in_administrator/3" do
    test "stores the administrator token in the session", %{
      conn: conn,
      administrator: administrator
    } do
      conn = AdministratorAuth.log_in_administrator(conn, administrator)
      assert token = get_session(conn, :administrator_token)

      assert get_session(conn, :live_socket_id) ==
               "administrators_sessions:#{Base.url_encode64(token)}"

      assert redirected_to(conn) == "/dashboard"
      assert Administration.get_administrator_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{
      conn: conn,
      administrator: administrator
    } do
      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> AdministratorAuth.log_in_administrator(administrator)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, administrator: administrator} do
      conn =
        conn
        |> put_session(:administrator_return_to, "/hello")
        |> AdministratorAuth.log_in_administrator(administrator)

      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{
      conn: conn,
      administrator: administrator
    } do
      conn =
        conn
        |> fetch_cookies()
        |> AdministratorAuth.log_in_administrator(administrator, %{"remember_me" => "true"})

      assert get_session(conn, :administrator_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :administrator_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_administrator/1" do
    test "erases session and cookies", %{conn: conn, administrator: administrator} do
      administrator_token = Administration.generate_administrator_session_token(administrator)

      conn =
        conn
        |> put_session(:administrator_token, administrator_token)
        |> put_req_cookie(@remember_me_cookie, administrator_token)
        |> fetch_cookies()
        |> AdministratorAuth.log_out_administrator()

      refute get_session(conn, :administrator_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Administration.get_administrator_by_session_token(administrator_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "administrators_sessions:abcdef-token"
      HubIdentityWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> AdministratorAuth.log_out_administrator()

      assert_receive %Phoenix.Socket.Broadcast{
        event: "disconnect",
        topic: "administrators_sessions:abcdef-token"
      }
    end

    test "works even if administrator is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> AdministratorAuth.log_out_administrator()
      refute get_session(conn, :administrator_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_administrator/2" do
    test "authenticates administrator from session", %{conn: conn, administrator: administrator} do
      administrator_token = Administration.generate_administrator_session_token(administrator)

      conn =
        conn
        |> put_session(:administrator_token, administrator_token)
        |> AdministratorAuth.fetch_current_administrator([])

      assert conn.assigns.current_administrator.id == administrator.id
    end

    test "authenticates administrator from cookies", %{conn: conn, administrator: administrator} do
      logged_in_conn =
        conn
        |> fetch_cookies()
        |> AdministratorAuth.log_in_administrator(administrator, %{"remember_me" => "true"})

      administrator_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> AdministratorAuth.fetch_current_administrator([])

      assert get_session(conn, :administrator_token) == administrator_token
      assert conn.assigns.current_administrator.id == administrator.id
    end

    test "does not authenticate if data is missing", %{conn: conn, administrator: administrator} do
      _ = Administration.generate_administrator_session_token(administrator)
      conn = AdministratorAuth.fetch_current_administrator(conn, [])
      refute get_session(conn, :administrator_token)
      refute conn.assigns.current_administrator
    end
  end

  describe "redirect_if_administrator_is_authenticated/2" do
    test "redirects if administrator is authenticated", %{
      conn: conn,
      administrator: administrator
    } do
      conn =
        conn
        |> assign(:current_administrator, administrator)
        |> AdministratorAuth.redirect_if_administrator_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/dashboard"
    end

    test "does not redirect if administrator is not authenticated", %{conn: conn} do
      conn = AdministratorAuth.redirect_if_administrator_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_administrator/2" do
    test "redirects if administrator is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> AdministratorAuth.require_authenticated_administrator([])
      assert conn.halted
      assert redirected_to(conn) == Routes.administrator_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | request_path: "/foo", query_string: ""}
        |> fetch_flash()
        |> AdministratorAuth.require_authenticated_administrator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :administrator_return_to) == "/foo"

      halted_conn =
        %{conn | request_path: "/foo", query_string: "bar=baz"}
        |> fetch_flash()
        |> AdministratorAuth.require_authenticated_administrator([])

      assert halted_conn.halted
      assert get_session(halted_conn, :administrator_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | request_path: "/foo?bar", method: "POST"}
        |> fetch_flash()
        |> AdministratorAuth.require_authenticated_administrator([])

      assert halted_conn.halted
      refute get_session(halted_conn, :administrator_return_to)
    end

    test "does not redirect if administrator is authenticated", %{
      conn: conn,
      administrator: administrator
    } do
      conn =
        conn
        |> assign(:current_administrator, administrator)
        |> AdministratorAuth.require_authenticated_administrator([])

      refute conn.halted
      refute conn.status
    end
  end
end
