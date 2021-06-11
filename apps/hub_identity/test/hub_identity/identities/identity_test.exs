defmodule HubIdentity.Identities.IdentityTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities.Identity

  describe "changeset/2" do
    test "with valid attributes returns valid changeset" do
      user = insert(:user)
      provider_config = insert(:provider_config)

      assert changeset =
               Identity.changeset(%Identity{}, %{
                 details: %{"a" => "b"},
                 reference: "abc_123",
                 user_id: user.id,
                 provider_config_id: provider_config.id
               })

      assert changeset.valid?
      assert changeset.changes.uid != nil
    end

    test "with invalid attributes returns error" do
      assert changeset = Identity.changeset(%Identity{}, %{})
      refute changeset.valid?
      assert changeset.errors[:reference] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:provider_config_id] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
    end
  end
end
