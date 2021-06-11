defmodule HubIdentity.Identities.UserTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities.User

  @valid_password "LongPassword"

  describe "identity_changeset/0" do
    test "returns a valid changeset with a randome hashed password" do
      assert changeset = User.identity_changeset()
      assert changeset.valid?
      assert byte_size(changeset.changes[:hashed_password]) == 43
      assert changeset.changes[:uid] != nil
    end
  end

  describe "password_changeset/3" do
    setup do
      user = insert(:user)
      %{user: user}
    end

    test "reurns a valid changeset when password and confirmation match", %{user: user} do
      assert changeset =
               User.password_changeset(user, %{
                 password: @valid_password,
                 password_confirmation: @valid_password
               })

      assert changeset.valid?
    end

    test "returns error changeset when password_confirmation and password don't match", %{
      user: user
    } do
      assert changeset =
               User.password_changeset(user, %{
                 password: @valid_password,
                 password_confirmation: "Nooupe!"
               })

      refute changeset.valid?

      assert changeset.errors[:password_confirmation] ==
               {"does not match password", [validation: :confirmation]}
    end

    test "returns error changeset when password is invalid", %{
      user: user
    } do
      assert changeset =
               User.password_changeset(user, %{
                 password: "Nooupe!",
                 password_confirmation: "Nooupe!"
               })

      refute changeset.valid?

      assert changeset.errors[:password] ==
               {"should be at least %{count} character(s)",
                [count: 12, validation: :length, kind: :min, type: :string]}
    end
  end

  describe "registration_changeset/3" do
    test "returns valid changeset with a valid password" do
      assert changeset = User.registration_changeset(%User{}, %{password: @valid_password})

      assert changeset.valid?
      assert changeset.changes[:hashed_password] != nil
      assert changeset.changes[:hashed_password] != @valid_password
      assert changeset.changes[:uid] != nil
    end

    test "returns error changeset when password is invalid" do
      assert changeset = User.registration_changeset(%User{}, %{password: "Nooupe!"})

      refute changeset.valid?

      assert changeset.errors[:password] ==
               {"should be at least %{count} character(s)",
                [count: 12, validation: :length, kind: :min, type: :string]}
    end
  end

  describe "web_registration_changeset/3" do
    test "returns valid changeset with a valid password" do
      assert changeset =
               User.web_registration_changeset(%User{}, %{
                 password: @valid_password,
                 password_confirmation: @valid_password
               })

      assert changeset.valid?
      assert changeset.changes[:hashed_password] != nil
      assert changeset.changes[:hashed_password] != @valid_password
      assert changeset.changes[:uid] != nil
    end

    test "returns error changeset when password_confirmation and password don't match" do
      assert changeset =
               User.web_registration_changeset(%User{}, %{
                 password: @valid_password,
                 password_confirmation: "Nooupe!"
               })

      refute changeset.valid?

      assert changeset.errors[:password_confirmation] ==
               {"does not match confirmation", [validation: :confirmation]}
    end

    test "returns error changeset when password is invalid" do
      assert changeset =
               User.web_registration_changeset(%User{}, %{
                 password: "Nooupe!",
                 password_confirmation: "Nooupe!"
               })

      refute changeset.valid?

      assert changeset.errors[:password] ==
               {"should be at least %{count} character(s)",
                [count: 12, validation: :length, kind: :min, type: :string]}
    end
  end

  describe "valid_password?/2" do
    test "returns true when the passwords match" do
      user = insert(:user)
      assert User.valid_password?(user, "LongPassword")
    end

    test "returns false when the passwords dont match" do
      user = insert(:user)
      refute User.valid_password?(user, "nottheLongPassword")
    end
  end
end
