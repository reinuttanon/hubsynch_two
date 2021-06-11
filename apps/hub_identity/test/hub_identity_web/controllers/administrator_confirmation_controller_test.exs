defmodule HubIdentityWeb.AdministratorConfirmationControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  alias HubIdentity.Administration
  alias HubIdentity.Repo
  import HubIdentity.AdministrationFixtures

  setup do
    %{administrator: administrator_fixture()}
  end

  describe "GET /administrators/confirm" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.administrator_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /administrators/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, administrator: administrator} do
      conn =
        post(conn, Routes.administrator_confirmation_path(conn, :create), %{
          "administrator" => %{"email" => administrator.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Administration.AdministratorToken, administrator_id: administrator.id).context ==
               "confirm"
    end

    test "does not send confirmation token if account is confirmed", %{
      conn: conn,
      administrator: administrator
    } do
      Repo.update!(Administration.Administrator.confirm_changeset(administrator))

      conn =
        post(conn, Routes.administrator_confirmation_path(conn, :create), %{
          "administrator" => %{"email" => administrator.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Administration.AdministratorToken, administrator_id: administrator.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.administrator_confirmation_path(conn, :create), %{
          "administrator" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Administration.AdministratorToken) == []
    end
  end

  describe "GET /administrators/confirm/:token" do
    test "confirms the given token once", %{conn: conn, administrator: administrator} do
      token =
        extract_administrator_token(fn url ->
          Administration.deliver_administrator_confirmation_instructions(administrator, url)
        end)

      conn = get(conn, Routes.administrator_confirmation_path(conn, :confirm, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Account confirmed successfully"
      assert Administration.get_administrator!(administrator.id).confirmed_at
      refute get_session(conn, :administrator_token)
      assert Repo.all(Administration.AdministratorToken) == []

      # When not logged in
      conn = get(conn, Routes.administrator_confirmation_path(conn, :confirm, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_administrator(administrator)
        |> get(Routes.administrator_confirmation_path(conn, :confirm, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, administrator: administrator} do
      conn = get(conn, Routes.administrator_confirmation_path(conn, :confirm, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Account confirmation link is invalid or it has expired"
      refute Administration.get_administrator!(administrator.id).confirmed_at
    end
  end
end
