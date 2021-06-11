defmodule HubIdentityWeb.AdministratorResetPasswordControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  alias HubIdentity.Administration
  alias HubIdentity.Repo
  import HubIdentity.AdministrationFixtures

  setup do
    %{administrator: administrator_fixture()}
  end

  describe "GET /administrators/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, Routes.administrator_reset_password_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /administrators/reset_password" do
    @tag :capture_log
    test "sends a new reset password token", %{conn: conn, administrator: administrator} do
      conn =
        post(conn, Routes.administrator_reset_password_path(conn, :create), %{
          "administrator" => %{"email" => administrator.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Administration.AdministratorToken, administrator_id: administrator.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.administrator_reset_password_path(conn, :create), %{
          "administrator" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Administration.AdministratorToken) == []
    end
  end

  describe "GET /administrators/reset_password/:token" do
    setup %{administrator: administrator} do
      token =
        extract_administrator_token(fn url ->
          Administration.deliver_administrator_reset_password_instructions(administrator, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.administrator_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.administrator_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /administrators/reset_password/:token" do
    setup %{administrator: administrator} do
      token =
        extract_administrator_token(fn url ->
          Administration.deliver_administrator_reset_password_instructions(administrator, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, administrator: administrator, token: token} do
      conn =
        put(conn, Routes.administrator_reset_password_path(conn, :update, token), %{
          "administrator" => %{
            "password" => "newLongPassword!",
            "password_confirmation" => "newLongPassword!"
          }
        })

      assert redirected_to(conn) == Routes.administrator_session_path(conn, :new)
      refute get_session(conn, :administrator_token)
      assert get_flash(conn, :info) =~ "Password reset successfully"

      assert Administration.get_administrator_by_email_and_password(
               administrator.email,
               "newLongPassword!"
             )
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.administrator_reset_password_path(conn, :update, token), %{
          "administrator" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, Routes.administrator_reset_password_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
