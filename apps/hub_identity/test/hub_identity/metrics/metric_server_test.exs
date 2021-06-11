defmodule HubIdentity.Metrics.MetricsServerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  alias HubIdentity.Metrics.MetricServer

  describe "create_resource_activity/2" do
    test "creates a new 'create' activity record" do
      email = insert(:email)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: email}

      {:ok, user_activity} = MetricServer.create_resource_activity(build_conn(), attrs)

      assert user_activity.owner_type == "Email"
      assert user_activity.owner_uid == email.uid
      assert user_activity.provider == "self"
      assert user_activity.remote_address == "127.0.0.1"
      assert user_activity.type == "Email.create"
      assert user_activity.uid != nil
    end
  end

  describe "create_authenticate_activity" do
    test "crates a new authenticated activity record" do
      user = insert(:user)

      attrs = %{
        owner_uid: user.uid,
        owner_type: "User",
        client_service_uid: "uid_12345",
        provider: "self",
        type: "AccessToken.create"
      }

      {:ok, user_activity} = MetricServer.create_authenticate_activity(build_conn(), attrs)

      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid == user.uid
      assert user_activity.provider == "self"
      assert user_activity.remote_address == "127.0.0.1"
      assert user_activity.type == "AccessToken.create"
      assert user_activity.uid != nil
    end
  end

  describe "delete_resource_activity" do
    test "creates a new authenticated activity record with a conn" do
      email = insert(:email)
      attrs = %{client_service_uid: "uid_12345", provider: "self", owner: email}

      {:ok, user_activity} = MetricServer.delete_resource_activity(build_conn(), attrs)

      assert user_activity.owner_type == "Email"
      assert user_activity.owner_uid == email.uid
      assert user_activity.provider == "self"
      assert user_activity.remote_address == "127.0.0.1"
      assert user_activity.type == "Email.delete"
      assert user_activity.uid != nil
    end

    test "creates a new authenticated activity record without a conn" do
      identity = insert(:identity)
      attrs = %{provider: "facebook", owner: identity}

      {:ok, user_activity} = MetricServer.delete_resource_activity(attrs)

      assert user_activity.owner_type == "Identity"
      assert user_activity.owner_uid == identity.uid
      assert user_activity.provider == "facebook"
      assert user_activity.type == "Identity.delete"
      assert user_activity.uid != nil
    end
  end
end
