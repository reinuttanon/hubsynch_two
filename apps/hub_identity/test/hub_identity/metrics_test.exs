defmodule HubIdentity.MetricsTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  alias HubIdentity.Metrics
  alias HubIdentity.Metrics.UserActivity

  describe "create_activities/4" do
    test "creates a new User, Email, and Identity activity record and returns the conn" do
      user = insert(:user)
      email = insert(:email, user: user)
      identity = insert(:identity, user: user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.create_activities(
                 conn,
                 %{user: user, email: email, identity: identity},
                 client_service.uid,
                 "facebook"
               )

      activities = Metrics.list_user_activities()

      assert length(activities) == 3

      assert Enum.any?(activities, fn activity -> activity.owner_uid == user.uid end)
      assert Enum.any?(activities, fn activity -> activity.owner_uid == email.uid end)
      assert Enum.any?(activities, fn activity -> activity.owner_uid == identity.uid end)
    end

    test "creates a new Email and User, activity record and returns the conn" do
      user = insert(:user)
      email = insert(:email, user: user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.create_activities(
                 conn,
                 %{user: user, email: email},
                 client_service.uid,
                 "self"
               )

      activities = Metrics.list_user_activities()

      assert length(activities) == 2

      assert Enum.any?(activities, fn activity -> activity.owner_uid == user.uid end)
      assert Enum.any?(activities, fn activity -> activity.owner_uid == email.uid end)
    end

    test "creates a new Identity activity record and returns the conn" do
      user = insert(:user)
      identity = insert(:identity, user: user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.create_activities(
                 conn,
                 %{user: user, identity: identity},
                 client_service.uid,
                 "google"
               )

      activities = Metrics.list_user_activities()

      assert length(activities) == 1

      refute Enum.any?(activities, fn activity -> activity.owner_uid == user.uid end)
      assert Enum.any?(activities, fn activity -> activity.owner_uid == identity.uid end)
    end

    test "creates a new Email activity record and returns the conn" do
      email = insert(:email)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.create_activities(
                 conn,
                 %{email: email},
                 client_service.uid,
                 "self"
               )

      activities = Metrics.list_user_activities()

      assert length(activities) == 1

      assert Enum.any?(activities, fn activity -> activity.owner_uid == email.uid end)
    end
  end

  describe "cookie_activity/4" do
    test "creates a cookie activity record and returns the conn" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.cookie_activity(
                 conn,
                 user,
                 client_service.uid
               )

      activity = Metrics.list_user_activities() |> hd()
      assert activity.owner_uid == user.uid
      assert activity.owner_type == "User"
      assert activity.type == "AccessCookie.create"
      assert activity.provider == "self"
    end
  end

  describe "delete_activity/4" do
    test "creates a delete activity record and returns the conn" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.delete_activity(
                 conn,
                 user,
                 client_service.uid
               )

      activity = Metrics.list_user_activities() |> hd()
      assert activity.owner_uid == user.uid
      assert activity.owner_type == "User"
      assert activity.type == "User.delete"
      assert activity.provider == "self"
    end
  end

  describe "delete_activity/2" do
    test "creates a delete activity record" do
      user = insert(:user)

      assert Metrics.list_user_activities() == []

      assert {:ok, activity} =
               Metrics.delete_activity(
                 user,
                 "facebook"
               )

      assert activity.owner_uid == user.uid
      assert activity.owner_type == "User"
      assert activity.type == "User.delete"
      assert activity.provider == "facebook"
    end
  end

  describe "token_activity/3" do
    test "creates a token activity record and returns the conn" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.cookie_activity(
                 conn,
                 user,
                 client_service.uid,
                 "AccessToken.create"
               )

      activity = Metrics.list_user_activities() |> hd()
      assert activity.owner_uid == user.uid
      assert activity.owner_type == "User"
      assert activity.type == "AccessToken.create"
      assert activity.provider == "self"
    end
  end

  describe "verification_activity/3" do
    test "creates a verification success record and returns the conn" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert Metrics.list_user_activities() == []

      conn = build_conn()

      assert conn ==
               Metrics.verification_activity(
                 conn,
                 user,
                 client_service.uid
               )

      activity = Metrics.list_user_activities() |> hd()
      assert activity.owner_uid == user.uid
      assert activity.owner_type == "User"
      assert activity.type == "Verification.success"
      assert activity.provider == "self"
    end
  end

  describe "user_activities" do
    alias HubIdentity.Metrics.UserActivity

    @valid_attrs params_for(:user_activity)
    @invalid_attrs %{owner_type: nil, owner_uid: nil, provider: nil, type: nil}

    test "list_user_activities/0 returns all user_activities" do
      user_activity = insert(:user_activity)
      [found] = Metrics.list_user_activities()
      assert found.uid == user_activity.uid
      assert found.client_service_uid == user_activity.client_service_uid
    end

    test "get_user_activity!/1 returns the user_activity with given id" do
      user_activity = insert(:user_activity)
      found = Metrics.get_user_activity!(user_activity.id)
      assert found.uid == user_activity.uid
      assert found.client_service_uid == user_activity.client_service_uid
    end

    test "create_user_activity/1 with valid data creates a user_activity" do
      assert {:ok, %UserActivity{} = user_activity} = Metrics.create_user_activity(@valid_attrs)
      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid == "user_uid_12345"
      assert user_activity.provider == "HubIdentity"
      assert user_activity.type == "User.create"
    end

    test "create_user_activity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metrics.create_user_activity(@invalid_attrs)
    end

    test "total_activities/2 returns activities for provider of type" do
      for _ <- 1..3 do
        insert(:user_activity, %{type: "User.create", provider: "google"})
        insert(:user_activity, %{type: "User.create", provider: "facebook"})
        insert(:user_activity, %{type: "AccessToken.create", provider: "google"})
        insert(:user_activity, %{type: "AccessToken.create", provider: "facebook"})
      end

      assert 3 = Metrics.total_activities("google", %{type: "User.create"})
    end

    test "total_activities/2 returns activities for provider of type and client_service ids" do
      uid1 = "00000001"
      uid2 = "00000002"
      uids = [uid1, uid2]

      for _ <- 1..3 do
        insert(:user_activity, %{
          type: "User.create",
          provider: "google",
          client_service_uid: uid1
        })

        insert(:user_activity, %{
          type: "User.create",
          provider: "google",
          client_service_uid: uid2
        })

        insert(:user_activity, %{type: "User.create", provider: "google"})

        insert(:user_activity, %{type: "User.create", provider: "facebook"})

        insert(:user_activity, %{
          type: "AccessToken.create",
          provider: "google",
          client_service_uid: uid1
        })

        insert(:user_activity, %{
          type: "AccessToken.create",
          provider: "google",
          client_service_uid: uid2
        })
      end

      assert 6 = Metrics.total_activities("google", uids, %{type: "User.create"})
    end
  end
end
