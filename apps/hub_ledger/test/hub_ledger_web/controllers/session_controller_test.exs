defmodule HubLedgerWeb.SessionControllerTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  alias HubLedger.Users

  setup :register_and_log_in_administrator

  describe "new/2" do
    test "renders new Session page" do
      conn = build_conn()
      conn = get(conn, Routes.session_path(conn, :new))
      response = html_response(conn, 302)
      assert response =~ "You are being"
    end
  end

  describe "create/2" do
    test "creates a new session for an existing user" do
      user = insert(:user, hub_identity_uid: "some_uid")
      conn = build_conn()
      conn = get(conn, Routes.session_path(conn, :create, %{"user_token" => "valid_token"}))
      response = html_response(conn, 302)
      assert conn.private.plug_session["user_id"] == user.id
      assert response =~ "You are being"
    end

    test "creates an access_request for an unexisting user" do
      conn = build_conn()
      conn = get(conn, Routes.session_path(conn, :create, %{"user_token" => "valid_token"}))
      response = html_response(conn, 302)

      access_request = Users.get_access_request(%{hub_identity_uid: "some_uid"})

      assert access_request != nil
      assert conn.private.plug_session["user_id"] == nil
      assert response =~ "You are being"
    end

    test "With invalid token returns does not create access_request and session" do
      conn = build_conn()
      conn = get(conn, Routes.session_path(conn, :create, %{"user_token" => "invalid_token"}))

      access_request = Users.get_access_request(%{hub_identity_uid: "some_uid"})

      assert access_request == nil
      assert conn.private.plug_session["user_id"] == nil
    end
  end

  describe "log_out/2" do
    test "logs in a User", %{conn: conn} do
      insert(:user)
      conn = get(conn, Routes.session_path(conn, :log_out))

      res = get_session(conn, :user)
      assert res == nil
    end
  end
end
