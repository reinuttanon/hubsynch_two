defmodule HubIdentity.Metrics.UserActivityTest do
  use HubIdentity.DataCase

  import Phoenix.ConnTest
  import HubIdentity.Factory

  alias HubIdentity.Metrics.UserActivity

  describe "changeset/3" do
    setup do
      user = insert(:user)

      header = [
        {"user-agent",
         "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"}
      ]

      conn = build_conn() |> Map.put(:req_headers, header)

      %{user: user, conn: conn}
    end

    test "assigns the owner and type when user", %{user: user, conn: conn} do
      attrs = %{
        client_service_uid: "uid_12345",
        owner_type: "User",
        owner_uid: user.uid,
        provider: "self",
        type: "AccessCookie.create"
      }

      changeset = UserActivity.changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.client_service_uid == "uid_12345"
      assert changeset.changes.owner_type == "User"
      assert changeset.changes.owner_uid == user.uid
      assert changeset.changes.provider == "self"
      assert changeset.changes.type == "AccessCookie.create"
      assert changeset.changes.uid != nil
    end

    test "assigns the conn values", %{user: user, conn: conn} do
      attrs = %{
        client_service_uid: "uid_12345",
        owner_type: "User",
        owner_uid: user.uid,
        provider: "self",
        type: "AccessCookie.create"
      }

      changeset = UserActivity.changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.remote_address == "127.0.0.1"

      assert changeset.changes.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"
    end

    test "does not error if no conn", %{user: user} do
      attrs = %{
        client_service_uid: "uid_12345",
        owner_type: "User",
        owner_uid: user.uid,
        provider: "self",
        type: "AccessCookie.create"
      }

      changeset = UserActivity.changeset(%UserActivity{}, attrs)

      assert changeset.valid?
    end

    test "does not error if no user_agent", %{user: user} do
      attrs = %{
        client_service_uid: "uid_12345",
        owner_type: "User",
        owner_uid: user.uid,
        provider: "self",
        type: "AccessCookie.create"
      }

      changeset = UserActivity.changeset(%UserActivity{}, attrs, build_conn())
      assert changeset.valid?
    end

    test "does not error if no remote_ip", %{user: user} do
      conn = build_conn() |> Map.put(:remote_ip, {})

      attrs = %{
        client_service_uid: "uid_12345",
        owner_type: "User",
        owner_uid: user.uid,
        provider: "self",
        type: "AccessCookie.create"
      }

      changeset = UserActivity.changeset(%UserActivity{}, attrs, conn)
      assert changeset.valid?
    end
  end

  describe "create_changeset/3" do
    setup do
      user = insert(:user)

      header = [
        {"user-agent",
         "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"}
      ]

      conn = build_conn() |> Map.put(:req_headers, header)

      %{user: user, conn: conn}
    end

    test "assigns the owner and type when user", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "User"
      assert changeset.changes.owner_uid == user.uid
      assert changeset.changes.type == "User.create"
    end

    test "assigns the owner and type when email", %{conn: conn} do
      email = insert(:email)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: email}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "Email"
      assert changeset.changes.owner_uid == email.uid
      assert changeset.changes.type == "Email.create"
    end

    test "assigns the owner and type when identity", %{conn: conn} do
      identity = insert(:identity)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: identity}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "Identity"
      assert changeset.changes.owner_uid == identity.uid
      assert changeset.changes.type == "Identity.create"
    end

    test "assigns the conn values", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.remote_address == "127.0.0.1"

      assert changeset.changes.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"
    end

    test "does not error if no conn", %{user: user} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs)

      assert changeset.valid?
    end

    test "does not error if no user_agent", %{user: user} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, build_conn())
      assert changeset.valid?
    end

    test "does not error if no remote_ip", %{user: user} do
      conn = build_conn() |> Map.put(:remote_ip, {})
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)
      assert changeset.valid?
    end

    test "assigns a uid", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.create_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?

      assert changeset.changes.uid != nil
    end
  end

  describe "delete_changeset/3" do
    setup do
      user = insert(:user)

      header = [
        {"user-agent",
         "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"}
      ]

      conn = build_conn() |> Map.put(:req_headers, header)

      %{user: user, conn: conn}
    end

    test "assigns the owner and type when user", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "User"
      assert changeset.changes.owner_uid == user.uid
      assert changeset.changes.type == "User.delete"
    end

    test "assigns the owner and type when email", %{conn: conn} do
      email = insert(:email)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: email}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "Email"
      assert changeset.changes.owner_uid == email.uid
      assert changeset.changes.type == "Email.delete"
    end

    test "assigns the owner and type when identity", %{conn: conn} do
      identity = insert(:identity)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: identity}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.owner_type == "Identity"
      assert changeset.changes.owner_uid == identity.uid
      assert changeset.changes.type == "Identity.delete"
    end

    test "assigns the conn values", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?
      assert changeset.changes.remote_address == "127.0.0.1"

      assert changeset.changes.user_agent ==
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.86 Safari/537.36"
    end

    test "does not error if no conn", %{user: user} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs)

      assert changeset.valid?
    end

    test "does not error if no user_agent", %{user: user} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, build_conn())
      assert changeset.valid?
    end

    test "does not error if no remote_ip", %{user: user} do
      conn = build_conn() |> Map.put(:remote_ip, {})
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)
      assert changeset.valid?
    end

    test "assigns a uid", %{user: user, conn: conn} do
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: user}
      changeset = UserActivity.delete_changeset(%UserActivity{}, attrs, conn)

      assert changeset.valid?

      assert changeset.changes.uid != nil
    end
  end
end
