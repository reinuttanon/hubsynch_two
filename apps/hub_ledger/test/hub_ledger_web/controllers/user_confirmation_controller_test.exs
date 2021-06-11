defmodule HubLedgerWeb.UserConfirmationControllerTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  setup :register_and_log_in_administrator

  describe "confirm/2" do
    test "Creates a new user and updates an access request to approved", %{conn: conn} do
      access_request = insert(:access_request)

      conn =
        get(
          conn,
          Routes.user_confirmation_path(conn, :confirm, %{"access_request" => access_request.id})
        )

      updated_access = HubLedger.Users.get_access_request!(access_request.id)

      response = html_response(conn, 302)

      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      assert response =~ "You are being"
      assert DateTime.compare(updated_access.approved_at, now) == :eq
      assert updated_access.approver_id == get_session(conn, :user_id)
      assert nil != HubLedger.Users.get_user(%{hub_identity_uid: "Some hub_identity_uid"})
    end

    test "Does nothing if access_request is already confirmed", %{conn: conn} do
      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      access_request =
        insert(:access_request, approved_at: now, approver_id: get_session(conn, :user_id))

      conn =
        get(
          conn,
          Routes.user_confirmation_path(conn, :confirm, %{"access_request" => access_request.id})
        )

      response = html_response(conn, 302)

      assert conn.private.phoenix_flash["error"] == "Request has been approved"
      assert response =~ "You are being"

      assert nil == HubLedger.Users.get_user(%{hub_identity_uid: "Some hub_identity_uid"})
    end

    test "Error if access request doesn't exist", %{conn: conn} do
      conn =
        get(
          conn,
          Routes.user_confirmation_path(conn, :confirm, %{"access_request" => 1_000_000})
        )

      response = html_response(conn, 302)

      assert conn.private.phoenix_flash["error"] == "User Confirmation failure"
      assert response =~ "You are being"

      assert nil == HubLedger.Users.get_user(%{hub_identity_uid: "Some hub_identity_uid"})
    end
  end
end
