defmodule HubIdentity.Identities.CurrentUserTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities.CurrentUser

  describe "build/2" do
    test "with a user and a provider returns a CurrentUser" do
      user = insert(:user)
      email = insert(:confirmed_email, user: user)

      current_user = CurrentUser.build(user, "HubIdentity")
      assert current_user.uid == user.uid
      assert current_user.email == email.address
      assert current_user.authenticated_by == "HubIdentity"
      assert current_user.authenticated_at != nil
    end
  end

  describe "build/3" do
    test "with a user, address and a provider returns a CurrentUser" do
      user = insert(:user)

      current_user = CurrentUser.build(user, "erin@hivelocity.co.jp", "HubIdentity")
      assert current_user.uid == user.uid
      assert current_user.email == "erin@hivelocity.co.jp"
      assert current_user.authenticated_by == "HubIdentity"
      assert current_user.authenticated_at != nil
    end
  end
end
