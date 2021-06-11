defmodule HubIdentityWeb.UserResetPasswordControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  alias HubIdentity.Identities
  import HubIdentity.Factory

  setup do
    user = insert(:user)
    email = insert(:confirmed_email, user: user)
    %{email: email, user: user, conn: build_conn()}
  end

  describe "GET /users/reset_password/:token" do
    setup %{email: email} do
      client_service = insert(:client_service)

      token =
        extract_user_token(fn url ->
          Identities.deliver_user_reset_password_instructions(email, url, client_service.id)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, Routes.user_reset_password_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/public_users/complete"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /users/reset_password/:token" do
    setup %{email: email} do
      client_service =
        insert(:client_service, pass_change_redirect_url: "www.somewhere.com/client/site/success")

      token =
        extract_user_token(fn url ->
          Identities.deliver_user_reset_password_instructions(email, url, client_service.id)
        end)

      %{token: token}
    end

    test "resets password once and redirects to the client service specified url", %{
      conn: conn,
      email: email,
      token: token
    } do
      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, token), %{
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == "www.somewhere.com/client/site/success"
      refute get_session(conn, :user_token)

      assert Identities.get_user_by_email_and_password(
               email.address,
               "new valid password"
             )
    end

    test "resets password once and redirects to the default HubIdentity success", %{
      conn: conn,
      email: email
    } do
      client_service = insert(:client_service, pass_change_redirect_url: nil)

      token =
        extract_user_token(fn url ->
          Identities.deliver_user_reset_password_instructions(email, url, client_service.id)
        end)

      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, token), %{
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == "/public_users/complete"
      refute get_session(conn, :user_token)

      assert Identities.get_user_by_email_and_password(
               email.address,
               "new valid password"
             )
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, token), %{
          "user" => %{
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
      conn =
        put(conn, Routes.user_reset_password_path(conn, :update, "oops"), %{
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert redirected_to(conn) == "/public_users/complete"
      assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
    end
  end
end
