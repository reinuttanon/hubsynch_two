defmodule HubIdentityWeb.AdministratorSessionControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  import HubIdentity.AdministrationFixtures

  setup do
    %{administrator: administrator_fixture()}
  end

  describe "GET /administrators/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.administrator_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn, administrator: administrator} do
      conn =
        conn
        |> log_in_administrator(administrator)
        |> get(Routes.administrator_session_path(conn, :new))

      assert redirected_to(conn) == "/dashboard"
    end
  end

  describe "POST /administrators/log_in" do
    test "logs the administrator in", %{conn: conn, administrator: administrator} do
      conn =
        post(conn, Routes.administrator_session_path(conn, :create), %{
          "administrator" => %{
            "email" => administrator.email,
            "password" => valid_administrator_password()
          }
        })

      assert get_session(conn, :administrator_token)
      assert redirected_to(conn) =~ "/dashboard"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      assert redirected_to(conn) =~ "/dashboard"
    end

    test "logs the administrator in with remember me", %{conn: conn, administrator: administrator} do
      conn =
        post(conn, Routes.administrator_session_path(conn, :create), %{
          "administrator" => %{
            "email" => administrator.email,
            "password" => valid_administrator_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_hub_identity_web_administrator_remember_me"]
      assert redirected_to(conn) =~ "/dashboard"
    end

    test "logs the administrator in with return to", %{conn: conn, administrator: administrator} do
      conn =
        conn
        |> init_test_session(administrator_return_to: "/foo/bar")
        |> post(Routes.administrator_session_path(conn, :create), %{
          "administrator" => %{
            "email" => administrator.email,
            "password" => valid_administrator_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{
      conn: conn,
      administrator: administrator
    } do
      conn =
        post(conn, Routes.administrator_session_path(conn, :create), %{
          "administrator" => %{"email" => administrator.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /administrators/log_out" do
    test "logs the administrator out", %{conn: conn, administrator: administrator} do
      conn =
        conn
        |> log_in_administrator(administrator)
        |> delete(Routes.administrator_session_path(conn, :delete))

      assert redirected_to(conn) == "/"
      refute get_session(conn, :administrator_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the administrator is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.administrator_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :administrator_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
