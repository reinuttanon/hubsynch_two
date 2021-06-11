defmodule HubIdentityWeb.AdministratorSettingsControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  alias HubIdentity.Administration
  import HubIdentity.AdministrationFixtures

  setup :register_and_log_in_administrator

  describe "GET /administrators/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.administrator_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if administrator is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.administrator_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.administrator_session_path(conn, :new)
    end
  end

  describe "PUT /administrators/settings (change password form)" do
    test "updates the administrator password and resets tokens", %{
      conn: conn,
      administrator: administrator
    } do
      new_password_conn =
        put(conn, Routes.administrator_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_administrator_password(),
          "administrator" => %{
            "password" => "newLongPassword!",
            "password_confirmation" => "newLongPassword!"
          }
        })

      assert redirected_to(new_password_conn) == Routes.administrator_settings_path(conn, :edit)

      assert get_session(new_password_conn, :administrator_token) !=
               get_session(conn, :administrator_token)

      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"

      assert Administration.get_administrator_by_email_and_password(
               administrator.email,
               "newLongPassword!"
             )
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.administrator_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "administrator" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :administrator_token) ==
               get_session(conn, :administrator_token)
    end
  end

  describe "PUT /administrators/settings (change email form)" do
    @tag :capture_log
    test "updates the administrator email", %{conn: conn, administrator: administrator} do
      conn =
        put(conn, Routes.administrator_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_administrator_password(),
          "administrator" => %{"email" => unique_administrator_email()}
        })

      assert redirected_to(conn) == Routes.administrator_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Administration.get_administrator_by_email(administrator.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.administrator_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "administrator" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /administrators/settings/confirm_email/:token" do
    setup %{administrator: administrator} do
      email = unique_administrator_email()

      token =
        extract_administrator_token(fn url ->
          Administration.deliver_update_email_instructions(
            %{administrator | email: email},
            administrator.email,
            url
          )
        end)

      %{token: token, email: email}
    end

    test "updates the administrator email once", %{
      conn: conn,
      administrator: administrator,
      token: token,
      email: email
    } do
      conn = get(conn, Routes.administrator_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.administrator_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Administration.get_administrator_by_email(administrator.email)
      assert Administration.get_administrator_by_email(email)

      conn = get(conn, Routes.administrator_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.administrator_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, administrator: administrator} do
      conn = get(conn, Routes.administrator_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.administrator_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Administration.get_administrator_by_email(administrator.email)
    end

    test "redirects if administrator is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.administrator_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.administrator_session_path(conn, :new)
    end
  end
end
