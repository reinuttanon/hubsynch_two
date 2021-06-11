defmodule HubLedger.UsersTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  alias HubLedger.Users

  setup :register_and_log_in_administrator

  describe "deliver_access_notification/3" do
    test "Approves an access request and sends a notification to the user", %{conn: conn} do
      access_request = insert(:access_request)

      {:ok, %{body: message, to: user}} =
        Users.deliver_access_notification(
          access_request.id,
          get_session(conn, :user_id),
          "some_url"
        )

      assert message ==
               "\n==============================\n\nHi test@hivelocity.co.jp,\n\nYour Hub-Ledger Account has been confirmed.\n\nYou can access to Hub-Ledger clicking the link below.\n\nsome_url\n\nIf you didn't create an account with us, please ignore this.\n\n==============================\n"

      assert user == "test@hivelocity.co.jp"
    end

    test "Returns error regular user tries to confirm an access request" do
      user = insert(:user)
      access_request = insert(:access_request)

      assert {:error, "Only admins can approve access requests"} ==
               Users.deliver_access_notification(access_request, user.id, "some_url")
    end

    test "Returns error if access request has been already confirm", %{conn: conn} do
      user = insert(:user)

      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      access_request = insert(:access_request, approved_at: now, approver_id: user.id)

      assert {:error, "Request has been approved"} ==
               Users.deliver_access_notification(
                 access_request.id,
                 get_session(conn, :user_id),
                 "some_url"
               )
    end

    test "Returns error if access request doesn't exist", %{conn: conn} do
      assert {:error, "User Confirmation failure"} ==
               Users.deliver_access_notification(4444, get_session(conn, :user_id), "some_url")
    end
  end

  describe "list_users" do
    test "Returns a list of users" do
      insert(:user)
      found_users = Users.list_users()
      # One is admin from setup, one is from this test insert
      assert length(found_users) == 2
    end
  end

  describe "create_user/1" do
    test "Creates a user" do
      {:ok, user} = Users.create_user(%{hub_identity_uid: "HubIdentity uid"})

      assert user.role == "user"
      assert user.hub_identity_uid == "HubIdentity uid"
      assert user.deleted_at == nil
      assert user.uuid != nil
    end

    test "Fails if user with same hub_identity_uid already exist" do
      insert(:user, hub_identity_uid: "HubIdentity uid")
      {:error, changeset} = Users.create_user(%{hub_identity_uid: "HubIdentity uid"})

      refute changeset.valid?

      assert changeset.errors[:hub_identity_uid] ==
               {"has already been taken",
                [{:constraint, :unique}, {:constraint_name, "users_hub_identity_uid_index"}]}
    end
  end

  describe "update_user/2" do
    test "Updates a user" do
      user = insert(:user)
      {:ok, user} = Users.update_user(user, %{role: "admin"})

      assert user.role == "admin"
      assert user.hub_identity_uid == "Hub Identity uid"
      assert user.deleted_at == nil
    end

    test "Returns error with invalid role" do
      user = insert(:user)
      {:error, changeset} = Users.update_user(user, %{role: "Invalid role"})

      refute changeset.valid?
    end
  end

  describe "delete_user/1" do
    test "Updates a user" do
      user = insert(:user)
      {:ok, user} = Users.delete_user(user)

      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      assert user.role == "user"
      assert user.uuid == "User uuid"
      assert user.hub_identity_uid == "Hub Identity uid"
      assert DateTime.compare(user.deleted_at, now) == :eq
    end
  end

  describe "access_requests" do
    alias HubLedger.Users.AccessRequest

    @valid_attrs %{approved_at: "2010-04-17T14:00:00Z", hub_identity_uid: "some hub_identity_uid"}
    @update_attrs %{
      approved_at: "2011-05-18T15:01:01Z",
      hub_identity_uid: "some updated hub_identity_uid"
    }
    @invalid_attrs %{approved_at: nil, uid: nil, approver_id: "some invalid approver_id"}

    def access_request_fixture(attrs \\ %{}) do
      {:ok, access_request} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_access_request()

      access_request
    end

    test "list_access_requests/0 returns all access_requests" do
      access_request = access_request_fixture()
      assert Users.list_access_requests() == [access_request]
    end

    test "get_access_request!/1 returns the access_request with given id" do
      access_request = access_request_fixture()
      assert Users.get_access_request!(access_request.id) == access_request
    end

    test "create_access_request/1 with valid data creates a access_request" do
      assert {:ok, %AccessRequest{} = access_request} = Users.create_access_request(@valid_attrs)
      assert access_request.approved_at == nil
      assert access_request.hub_identity_uid == "some hub_identity_uid"
    end

    test "create_access_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_access_request(@invalid_attrs)
    end

    test "update_access_request/2 with valid data updates the access_request" do
      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      access_request = access_request_fixture()

      assert {:ok, %AccessRequest{} = access_request} =
               Users.update_access_request(access_request, @update_attrs)

      assert DateTime.compare(access_request.approved_at, now) == :eq
    end

    test "update_access_request/2 with invalid data returns error changeset" do
      access_request = access_request_fixture()

      assert {:error, %Ecto.Changeset{} = changeset} =
               Users.update_access_request(access_request, @invalid_attrs)

      assert access_request == Users.get_access_request!(access_request.id)
      assert changeset.errors[:approver_id] == {"is invalid", [type: :id, validation: :cast]}
    end

    test "delete_access_request/1 deletes the access_request" do
      access_request = access_request_fixture()
      assert {:ok, %AccessRequest{}} = Users.delete_access_request(access_request)
      assert_raise Ecto.NoResultsError, fn -> Users.get_access_request!(access_request.id) end
    end

    test "delete_access_request/1 error when tries to delete approved access request" do
      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      user = insert(:user)
      access_request = insert(:access_request, approved_at: now, approver_id: user.id)
      assert {:error, message} = Users.delete_access_request(access_request)
      assert message == "Cannot delete approved access request"
    end

    test "change_access_request/1 returns a access_request changeset" do
      access_request = access_request_fixture()
      assert %Ecto.Changeset{} = Users.change_access_request(access_request)
    end
  end
end
