defmodule HubIdentity.IdentitiesTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities
  alias HubIdentity.Identities.{Email, Identity, User, UserToken}
  alias HubIdentity.Repo

  describe "emails" do
    test "get_email!/1 returns the email with given id" do
      email = insert(:email)
      found = Identities.get_email!(email.id)
      assert found.id == email.id
      assert found.address == email.address
    end

    test "get_email/1 returns the email with the address" do
      email = insert(:email)
      found = Identities.get_email(%{address: email.address})
      assert found.id == email.id
      assert found.address == email.address
    end

    test "get_email/1 returns the email if the email exists and is matches the users uid" do
      user = insert(:user)
      email = insert(:email, user: user)

      found = Identities.get_email(%{user_uid: user.uid, uid: email.uid})
      assert found.user_id == user.id
      assert found.address == email.address
      assert found.id == email.id
    end

    test "get_email/1 returns nil if the email does not exist" do
      user = insert(:user)
      assert nil == Identities.get_email(%{user_uid: user.uid, uid: "555nooouupe"})
    end

    test "get_email/1 returns nil if the email does not match the user" do
      user = insert(:user)
      email = insert(:email)

      assert email.user_id != user.id
      assert nil == Identities.get_email(%{user_uid: user.uid, uid: email.uid})
    end

    test "get_email/1 returns nil if the user does not exist" do
      email = insert(:email)
      assert nil == Identities.get_email(%{user_uid: "555nnooupe", uid: email.uid})
    end

    test "get_email/1 returns nil if no email is found" do
      assert Identities.get_email(%{address: "not@here.com"}) == nil
    end

    test "verify_address/1 with a valid email address returns ok tuple" do
      assert {:ok, changeset} = Identities.verify_address("erin@hivelocity.co.jp")
      assert changeset.valid?
    end

    test "verify_address/1 with an invalid email address returns error tuple" do
      assert {:error, changeset} = Identities.verify_address("")
      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"can't be blank", [validation: :required]}
    end

    test "verify_address/1 with an exisiting email address returns error tuple" do
      insert(:email, address: "erin@hivelocity.co.jp")
      assert {:error, changeset} = Identities.verify_address("erin@hivelocity.co.jp")
      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"has already been taken", [validation: :unsafe_unique, fields: [:address]]}
    end

    test "create_confirmed_email/1 with valid attributes returns an ok tuple with email" do
      user = insert(:user)

      assert {:ok, email} =
               Identities.create_confirmed_email(%{
                 address: "erin@hivelocity.co.jp",
                 user_id: user.id
               })

      assert email.address == "erin@hivelocity.co.jp"
      assert email.confirmed_at != nil
      assert email.uid != nil
    end

    test "create_confirmed_email/1 with invalid email returns error tuple" do
      user = insert(:user)

      assert {:error, changeset} =
               Identities.create_confirmed_email(%{
                 address: "noupe",
                 user_id: user.id
               })

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"must have the @ sign and no spaces", [validation: :format]}
    end

    test "create_confirmed_email/1 with an existing email returns error tuple" do
      user = insert(:user)
      email = insert(:email)

      assert {:error, changeset} =
               Identities.create_confirmed_email(%{
                 address: email.address,
                 user_id: user.id
               })

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"has already been taken", [validation: :unsafe_unique, fields: [:address]]}
    end

    test "delete_email/1 deletes the email" do
      email = insert(:email)
      assert {:ok, %Email{}} = Identities.delete_email(email)
      assert_raise Ecto.NoResultsError, fn -> Identities.get_email!(email.id) end
    end
  end

  describe "users" do
    setup do
      %{user: insert(:user)}
    end

    test "get_user!/1 raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Identities.get_user!(-1)
      end
    end

    test "get_user!/1 returns the user with the given id", %{user: %User{id: id}} do
      assert %User{id: ^id} = Identities.get_user!(id)
    end

    test "get_user!/2 returns the user with preloaded emails", %{user: user} do
      email = insert(:email, user: user)
      found_user = Identities.get_user!(user.id, preload: true)
      assert found_user.id == user.id
      assert Enum.any?(found_user.emails, fn e -> e.uid == email.uid end)
    end

    test "get_user/1 returns the user with the uid", %{user: %User{id: id, uid: uid}} do
      assert %User{id: ^id} = Identities.get_user(%{uid: uid})
    end

    test "get_user/1 returns nil if no user for uid" do
      assert nil == Identities.get_user(%{uid: "no_user"})
    end

    test "user_registration_changeset/1 with valid password returns ok tuple" do
      assert {:ok, changeset} =
               Identities.user_registration_changeset(%{password: "LongPassword!"})

      assert changeset.valid?
    end

    test "user_registration_changeset/1 with invalid password returns error tuple" do
      assert {:error, changeset} = Identities.user_registration_changeset(%{password: ""})
      refute changeset.valid?
    end

    test "web_registration_changeset/1 with valid password and confirmation returns ok tuple" do
      assert {:ok, changeset} =
               Identities.web_registration_changeset(%{
                 password: "LongPassword!",
                 password_confirmation: "LongPassword!"
               })

      assert changeset.valid?
    end

    test "web_registration_changeset/1 with invalid password returns error tuple" do
      assert {:error, changeset} =
               Identities.web_registration_changeset(%{password: "", password_confirmation: ""})

      refute changeset.valid?
      assert changeset.errors[:password] == {"can't be blank", [validation: :required]}

      assert changeset.errors[:password_confirmation] ==
               {"can't be blank", [validation: :required]}
    end

    test "web_registration_changeset/1 with non matching passwords returns error tuple" do
      assert {:error, changeset} =
               Identities.web_registration_changeset(%{
                 password: "LongPassword!",
                 password_confirmation: "not_a_match_but_long"
               })

      refute changeset.valid?

      assert changeset.errors[:password_confirmation] ==
               {"does not match confirmation", [validation: :confirmation]}
    end

    test "change_user_password/2 returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Identities.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "change_user_password/2 allows fields to be set" do
      changeset =
        Identities.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end

    test "update_user_password/3 validates password", %{user: user} do
      {:error, changeset} =
        Identities.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "update_user_password/3 validates maximum values for password for security", %{
      user: user
    } do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Identities.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "update_user_password/3 validates current password", %{user: user} do
      {:error, changeset} =
        Identities.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "update_user_password/3 updates the password", %{user: user} do
      email = insert(:email, user: user, primary: true)

      {:ok, user} =
        Identities.update_user_password(user, valid_user_password(), %{
          password: "new_valid_password"
        })

      assert is_nil(user.password)

      assert Identities.get_user_by_email_and_password(
               email.address,
               "new_valid_password"
             )
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Identities.generate_user_session_token(user)

      {:ok, _} =
        Identities.update_user_password(user, valid_user_password(), %{
          password: "new_valid_password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "delete_user/1 soft deletes the user", %{user: user} do
      insert(:email, user: user)
      insert(:email, user: user)
      insert(:identity, user: user)

      assert {:ok,
              %{
                delete_all_emails: {count_email, _},
                delete_all_identities: {count_identities, _},
                update: updated_user
              }} = Identities.delete_user(user)

      assert count_email == 2
      assert count_identities == 1
      assert updated_user.id == user.id
      refute Repo.get_by(Email, user_id: user.id)
      refute Identities.get_user(%{uid: user.uid})
      deleted_user = Repo.get(User, user.id)
      assert deleted_user.deleted_at != nil
    end

    test "inspect/2 does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "identities" do
    test "get_identity!/1 returns the identity with given id" do
      identity = insert(:identity)
      found = Identities.get_identity!(identity.id)
      assert found.id == identity.id
      assert found.uid == identity.uid
    end

    test "get_identity/1 returns the identity with the given params" do
      provider_config = insert(:provider_config)
      user = insert(:user)
      identity = insert(:identity, user: user, provider_config: provider_config)

      other_provider = insert(:provider_config)
      insert(:identity, user: user, provider_config: other_provider)

      other_user = insert(:user)
      insert(:identity, user: other_user, provider_config: provider_config)

      found =
        Identities.get_identity(%{
          provider_config_id: provider_config.id,
          reference: identity.reference
        })

      assert found.id == identity.id
      assert found.uid == identity.uid
      assert found.user_id == user.id
      assert found.provider_config_id == provider_config.id
    end

    test "get_identity/1 returns nil if identity not found" do
      assert nil ==
               Identities.get_identity(%{
                 user_id: 555,
                 provider_config_id: 8,
                 reference: "kfasjdljlaj"
               })
    end

    test "create_identity/1 with valid data creates a identity" do
      provider = insert(:provider_config)
      user = insert(:user)
      params = %{user_id: user.id, provider_config_id: provider.id, reference: "ref_12345"}
      assert {:ok, %Identity{} = identity} = Identities.create_identity(params)
      assert identity.user_id == user.id
      assert identity.provider_config_id == provider.id
      assert identity.reference == "ref_12345"
      assert identity.uid != nil
    end

    test "create_identity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_identity(%{})
    end

    test "delete_identity/1 deletes the identity" do
      identity = insert(:identity)
      assert {:ok, %Identity{}} = Identities.delete_identity(identity)
      assert_raise Ecto.NoResultsError, fn -> Identities.get_identity!(identity.id) end
    end
  end
end
