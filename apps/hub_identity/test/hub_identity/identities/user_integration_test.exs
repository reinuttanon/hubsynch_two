defmodule HubIdentity.Identities.UserIntegrationTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Identities
  alias HubIdentity.Identities.{User, UserToken}
  alias HubIdentity.Repo

  describe "delete_user_data/1" do
    test "deletes the identity record and creates a user_activity" do
      user = insert(:user)
      provider_config = insert(:provider_config)
      identity = insert(:identity, user: user, provider_config: provider_config)

      assert {:ok, user_activity} =
               Identities.delete_user_data(provider_config, identity.reference)

      assert user_activity.owner_type == "Identity"
      assert user_activity.owner_uid == identity.uid
      assert user_activity.provider == provider_config.name
      assert user_activity.type == "Identity.delete"

      assert_raise Ecto.NoResultsError, fn ->
        Identities.get_identity!(identity.id)
      end
    end
  end

  describe "find_or_create_user_from_identity/1" do
    setup do
      provider_config = insert(:provider_config)
      user = insert(:user)
      email = insert(:email, user: user)
      client_service = insert(:client_service)

      %{
        user: user,
        provider_config: provider_config,
        email: email,
        client_service: client_service
      }
    end

    test "returns the identity if a user, email, and identity exist", %{
      user: user,
      provider_config: provider_config,
      email: email
    } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      {:ok, %{user: found_user, address: address}} =
        Identities.find_or_create_user_from_identity(%{
          provider_config_id: provider_config.id,
          reference: identity.reference,
          email: email.address
        })

      assert found_user.id == user.id
      assert found_user.uid == user.uid
      assert address == email.address
    end

    test "adds the email if the email is new and confirmed from provider", %{
      user: user,
      provider_config: provider_config
    } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      {:ok, %{user: found_user, email: new_email}} =
        Identities.find_or_create_user_from_identity(%{
          provider_config_id: provider_config.id,
          reference: identity.reference,
          email: "new_erin@hivelocity.co.jp",
          email_verified: true
        })

      assert found_user.id == user.id
      assert found_user.uid == user.uid

      assert new_email.user_id == user.id
      assert new_email.address == "new_erin@hivelocity.co.jp"
      assert new_email.confirmed_at != nil
      refute new_email.primary
    end

    test "if not a confirmed new email returns email verification required and the user", %{
      user: user,
      provider_config: provider_config
    } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      assert {:verify_email, %{provider_info: provider_info, user: found_user}} =
               Identities.find_or_create_user_from_identity(%{
                 provider_config_id: provider_config.id,
                 reference: identity.reference,
                 email: "new_erin@hivelocity.co.jp",
                 email_verified: false
               })

      assert user.uid == found_user.uid
      assert provider_info.email == "new_erin@hivelocity.co.jp"
      assert nil == Identities.get_email(%{address: "new_erin@hivelocity.co.jp"})
    end

    test "if the email matches a user creates a new identity ", %{
      provider_config: provider_config,
      user: user
    } do
      email = insert(:confirmed_email, user: user)

      {:ok, %{identity: new_identity, user: found_user}} =
        Identities.find_or_create_user_from_identity(%{
          provider_config_id: provider_config.id,
          reference: "ref_12345678",
          email: email.address
        })

      assert found_user.uid == user.uid

      assert new_identity.user_id == user.id
      assert new_identity.provider_config_id == provider_config.id
      assert new_identity.reference == "ref_12345678"
      assert new_identity.uid != nil
    end

    test "returns error if a user exists with provider reference and different user exists with same email" do
      new_user = insert(:user)
      new_user_identity = insert(:identity, user: new_user)
      existing_email = insert(:email)

      refute existing_email.user_id == new_user.id

      assert {:error, :email_taken} ==
               Identities.find_or_create_user_from_identity(%{
                 provider_config_id: new_user_identity.provider_config_id,
                 reference: new_user_identity.reference,
                 email: existing_email.address
               })
    end

    test "with a confirmed email from a provider returns ok with a created user, email, and identity",
         %{provider_config: provider_config} do
      {:ok, %{email: new_email, identity: new_identity, user: new_user}} =
        Identities.find_or_create_user_from_identity(%{
          provider_config_id: provider_config.id,
          reference: "ref_12345678",
          email: "erin@hivelocity.co.jp",
          email_verified: true
        })

      assert new_email.user_id == new_user.id
      assert new_email.address == "erin@hivelocity.co.jp"

      assert new_identity.user_id == new_user.id
      assert new_identity.reference == "ref_12345678"

      assert new_user.uid != nil
    end

    test "returns verify_email with the provider params when email is not confirmed and no user or identity exist",
         %{
           provider_config: provider_config
         } do
      params = %{
        provider_config_id: provider_config.id,
        reference: "ref_12345678",
        email: "erin@hivelocity.co.jp",
        email_verified: false
      }

      {:verify_email, returned_params} = Identities.find_or_create_user_from_identity(params)

      assert returned_params == params

      assert nil == Identities.get_email(%{address: "new_erin@hivelocity.co.jp"})

      assert nil ==
               Identities.get_identity(%{
                 provider_config_id: provider_config.id,
                 reference: "ref_12345678"
               })
    end
  end

  describe "get_user_by_identity/1" do
    test "returns the user if one exists" do
      user = insert(:user)
      identity = insert(:identity, user: user)

      found_user =
        Identities.get_user_by_identity(%{
          reference: identity.reference,
          provider_config_id: identity.provider_config_id
        })

      assert found_user.id == user.id
      assert found_user.uid == user.uid
    end

    test "returns nil if no user exists" do
      provider_config = insert(:provider_config)

      assert nil ==
               Identities.get_user_by_identity(%{
                 reference: "1234",
                 provider_config_id: provider_config.id
               })
    end

    test "returns nil if a user has been soft deleted" do
      user = insert(:user, deleted_at: DateTime.utc_now())
      identity = insert(:identity, user: user)

      assert nil ==
               Identities.get_user_by_identity(%{
                 reference: identity.reference,
                 provider_config_id: identity.provider_config_id
               })
    end
  end

  describe "get_user_by_email/2" do
    test "returns the user if the email exists" do
      user = insert(:user)
      email = insert(:email, user: user)
      %User{} = found = Identities.get_user_by_email(email.address)
      assert found.uid == user.uid
      assert found.id == user.id
    end

    test "returns the user with all the users emails loaded" do
      user = insert(:user)

      for _ <- 1..3 do
        insert(:email, user: user, primary: false)
      end

      email = insert(:email, user: user, primary: true)
      %User{} = found = Identities.get_user_by_email(email.address)
      assert length(found.emails) == 4
    end

    test "returns the user if the email exists and is primary when primary: true" do
      user = insert(:user)
      primary = insert(:email, user: user, primary: true)
      insert(:email, user: user, primary: false)
      %User{} = found = Identities.get_user_by_email(primary.address, primary: true)
      assert found.uid == user.uid
      assert found.id == user.id
    end

    test "returns the user if the email exists and is primary when primary: false" do
      user = insert(:user)
      email = insert(:email, user: user, primary: false)
      insert(:email, user: user, primary: true)
      %User{} = found = Identities.get_user_by_email(email.address, primary: false)
      assert found.uid == user.uid
      assert found.id == user.id
    end

    test "returns nil if the email does not exist" do
      assert nil == Identities.get_user_by_email("no@here.com")
    end

    test "returns nil if the user is soft deleted" do
      user = insert(:user, deleted_at: DateTime.utc_now())
      email = insert(:email, user: user)

      assert user.deleted_at != nil

      assert nil == Identities.get_user_by_email(email.address)
    end

    test "reurns nil if the primary: true and email not primary" do
      user = insert(:user)
      insert(:email, user: user, primary: true)
      email = insert(:email, user: user, primary: false)

      assert nil == Identities.get_user_by_email(email.address, primary: true)
    end
  end

  describe "get_user_primary_email/1" do
    test "returns the users primary email" do
      user = insert(:user)
      primary = insert(:email, user: user, primary: true)
      insert(:email, user: user)
      insert(:email, user: user)

      found_user = Identities.get_user(%{uid: user.uid})
      assert {:ok, found_primary} = Identities.get_user_primary_email(found_user)
      assert found_primary.uid == primary.uid
    end

    test "returns an error if no primary email" do
      user = insert(:user)
      insert(:email, user: user)
      insert(:email, user: user)

      found_user = Identities.get_user(%{uid: user.uid})

      assert {:error, :primary_email_not_found} == Identities.get_user_primary_email(found_user)
    end

    test "returns the users primary email when emails are not loaded" do
      user = insert(:user)
      primary = insert(:email, user: user, primary: true)
      insert(:email, user: user)
      insert(:email, user: user)

      refute Ecto.assoc_loaded?(user.emails)

      assert {:ok, found_primary} = Identities.get_user_primary_email(user)
      assert found_primary.uid == primary.uid
    end
  end

  describe "get_user_by_email_and_password/3" do
    test "does not return the user if the email does not exist" do
      assert nil ==
               Identities.get_user_by_email_and_password(
                 "unknown@example.com",
                 "hello world!"
               )
    end

    test "does not return the user if the email is not users primary email" do
      user = insert(:user)
      email = insert(:email, user: user, primary: false)
      insert(:email, user: user, primary: true)

      assert nil == Identities.get_user_by_email_and_password(email.address, "LongPassword")
    end

    test "does not return the user if the password is not valid" do
      user = insert(:user)
      email = insert(:email, user: user, primary: true)
      assert nil == Identities.get_user_by_email_and_password(email.address, "invalid")
    end

    test "returns the user if the email is primary and password is valid" do
      %User{id: id} = user = insert(:user)
      email = insert(:email, user: user, primary: true)

      assert %User{id: ^id} =
               Identities.get_user_by_email_and_password(
                 email.address,
                 "LongPassword"
               )
    end
  end

  describe "handle_confirmation/1" do
    setup do
      provider_config = insert(:provider_config)
      user = insert(:user)
      email = insert(:email, user: user)
      client_service = insert(:client_service)

      %{
        user: user,
        provider_config: provider_config,
        email: email,
        client_service: client_service
      }
    end

    test "when user and address inserts a user and email" do
      {:ok, user_changeset} = Identities.user_registration_changeset(%{password: "LongPassword!"})

      assert {:ok, %{email: email, user: user}} =
               Identities.handle_confirmation(%{
                 user: user_changeset,
                 address: "erin@hivelocity.co.jp"
               })

      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
      assert user.uid != nil

      assert email.address == "erin@hivelocity.co.jp"
      assert email.confirmed_at != nil
      assert email.primary
      assert email.user_id == user.id
      assert email.uid != nil
    end

    test "when user and address returns an error if email exists" do
      {:ok, user_changeset} = Identities.user_registration_changeset(%{password: "LongPassword!"})

      insert(:email, address: "erin@hivelocity.co.jp")

      assert {:error, :email, changeset, _} =
               Identities.handle_confirmation(%{
                 user: user_changeset,
                 address: "erin@hivelocity.co.jp"
               })

      assert changeset.errors[:address] ==
               {"has already been taken", [validation: :unsafe_unique, fields: [:address]]}
    end

    test "when provider_info returns the identity if a user, email, and identity exist", %{
      user: user,
      provider_config: provider_config,
      email: email
    } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      {:ok, %{user: found_user, address: address}} =
        Identities.handle_confirmation(%{
          user: nil,
          address: nil,
          provider_info: %{
            provider_config_id: provider_config.id,
            reference: identity.reference,
            email: email.address
          }
        })

      assert found_user.id == user.id
      assert found_user.uid == user.uid
      assert address == email.address
    end

    test "when provider_info adds the email if the email is new and confirmed from provider", %{
      user: user,
      provider_config: provider_config
    } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      {:ok, %{user: found_user, email: new_email}} =
        Identities.handle_confirmation(%{
          user: nil,
          address: nil,
          provider_info: %{
            provider_config_id: provider_config.id,
            reference: identity.reference,
            email: "new_erin@hivelocity.co.jp",
            email_verified: true
          }
        })

      assert found_user.id == user.id
      assert found_user.uid == user.uid

      assert new_email.user_id == user.id
      assert new_email.address == "new_erin@hivelocity.co.jp"
      assert new_email.confirmed_at != nil
      refute new_email.primary
    end

    test "when provider info if not a confirmed new email returns email verification required and the user",
         %{
           user: user,
           provider_config: provider_config
         } do
      identity = insert(:identity, user: user, provider_config: provider_config)

      assert {:verify_email, %{provider_info: provider_info, user: found_user}} =
               Identities.handle_confirmation(%{
                 user: nil,
                 address: nil,
                 provider_info: %{
                   provider_config_id: provider_config.id,
                   reference: identity.reference,
                   email: "new_erin@hivelocity.co.jp",
                   email_verified: false
                 }
               })

      assert user.uid == found_user.uid
      assert provider_info.email == "new_erin@hivelocity.co.jp"
    end

    test "when provider info if the email matches a user creates a new identity ", %{
      provider_config: provider_config,
      user: user
    } do
      email = insert(:confirmed_email, user: user)

      {:ok, %{identity: new_identity, user: found_user}} =
        Identities.handle_confirmation(%{
          user: nil,
          address: nil,
          provider_info: %{
            provider_config_id: provider_config.id,
            reference: "ref_12345678",
            email: email.address
          }
        })

      assert found_user.uid == user.uid

      assert new_identity.user_id == user.id
      assert new_identity.provider_config_id == provider_config.id
      assert new_identity.reference == "ref_12345678"
      assert new_identity.uid != nil
    end

    test "when provider info returns error if a user exists with provider reference and different user exists with same email" do
      new_user = insert(:user)
      new_user_identity = insert(:identity, user: new_user)
      existing_email = insert(:email)

      refute existing_email.user_id == new_user.id

      assert {:error, :email_taken} ==
               Identities.handle_confirmation(%{
                 user: nil,
                 address: nil,
                 provider_info: %{
                   provider_config_id: new_user_identity.provider_config_id,
                   reference: new_user_identity.reference,
                   email: existing_email.address
                 }
               })
    end

    test "when provider info with a confirmed email from a provider returns ok with a created user, email, and identity",
         %{provider_config: provider_config} do
      {:ok, %{email: new_email, identity: new_identity, user: new_user}} =
        Identities.handle_confirmation(%{
          user: nil,
          address: nil,
          provider_info: %{
            provider_config_id: provider_config.id,
            reference: "ref_12345678",
            email: "erin@hivelocity.co.jp",
            email_verified: true
          }
        })

      assert new_email.user_id == new_user.id
      assert new_email.address == "erin@hivelocity.co.jp"

      assert new_identity.user_id == new_user.id
      assert new_identity.reference == "ref_12345678"

      assert new_user.uid != nil
    end

    test "when provider info returns verify_email with the provider params when email is not confirmed and no user or identity exist",
         %{
           provider_config: provider_config
         } do
      params = %{
        provider_config_id: provider_config.id,
        reference: "ref_12345678",
        email: "erin@hivelocity.co.jp",
        email_verified: false
      }

      {:verify_email, returned_params} = Identities.handle_confirmation(%{provider_info: params})

      assert returned_params == params
    end

    test "with valid email address and valid user_id creates confirm email" do
      user = insert(:user)

      {:ok, %{email: email}} =
        Identities.handle_confirmation(%{
          provider_info: nil,
          address: "gmail@gmail.com",
          user: %{user_id: user.id}
        })

      assert email.address == "gmail@gmail.com"
      assert email.confirmed_at != nil
      assert email.user_id == user.id
    end

    test "with invalid email address returns error and changeset" do
      user = insert(:user)

      assert {:error, changeset} =
               Identities.handle_confirmation(%{address: "bad_email", user: %{user_id: user.id}})

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"must have the @ sign and no spaces", [validation: :format]}
    end

    test "with existing email address returns error and changeset" do
      user = insert(:user)
      email = insert(:email)

      assert {:error, changeset} =
               Identities.handle_confirmation(%{address: email.address, user: %{user_id: user.id}})

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"has already been taken", [{:validation, :unsafe_unique}, {:fields, [:address]}]}
    end

    test "with invalid user returns error and changeset" do
      assert {:error, changeset} =
               Identities.handle_confirmation(%{address: "gmail@gmail.com", user: %{user_id: 555}})

      refute changeset.valid?

      assert changeset.errors[:user_id] ==
               {"does not exist", [constraint: :foreign, constraint_name: "emails_user_id_fkey"]}
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    test "sends token through notification to the email" do
      {:ok, %{body: body, to: to}} =
        Identities.deliver_user_confirmation_instructions(
          "email@gmail.com",
          "deliver/url/here"
        )

      assert to == "email@gmail.com"
      assert body =~ "deliver/url/here"
    end
  end

  describe "change_user_primary_email/1" do
    setup do
      user = insert(:user)

      %{user: user}
    end

    test "with an already primary email returns the ok tuple", %{user: user} do
      primary_email = insert(:email, user: user, primary: true)

      assert primary_email.primary

      assert Identities.change_user_primary_email(primary_email) ==
               {:ok, primary_email}
    end

    test "with a confirmed email returns the ok tuple", %{user: user} do
      primary_email = insert(:confirmed_email, user: user, primary: true)
      email = insert(:email, user: user, primary: false, confirmed_at: DateTime.utc_now())

      assert primary_email.primary
      refute email.primary
      refute email.confirmed_at == nil

      assert {:ok, new_primary_email} = Identities.change_user_primary_email(email)

      assert new_primary_email.primary
      assert new_primary_email.id == email.id

      old_primary_email = Identities.get_email!(primary_email.id)
      refute old_primary_email.primary
    end

    test "with an unconfirmed email returns an error tuple with a changeset", %{user: user} do
      primary_email = insert(:confirmed_email, user: user, primary: true)
      email = insert(:email, user: user, primary: false, confirmed_at: nil)

      assert primary_email.primary
      refute email.primary
      assert email.confirmed_at == nil

      assert {:error, changeset} = Identities.change_user_primary_email(email)

      assert changeset.errors[:confirmation] == {"email must be confirmed", []}

      old_primary_email = Identities.get_email!(primary_email.id)
      assert old_primary_email.primary
    end

    test "a user with no primary email returns an error", %{user: user} do
      email = insert(:email, user: user, primary: false)
      insert(:email, user: user, primary: false)

      assert {:error, :primary_email_not_found} ==
               Identities.change_user_primary_email(email)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: insert(:user)}
    end

    test "generates a token", %{user: user} do
      token = Identities.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      new_user = insert(:user)

      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: new_user.id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Identities.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Identities.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Identities.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Identities.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = insert(:user)
      token = Identities.generate_user_session_token(user)
      assert Identities.delete_session_token(token) == :ok
      refute Identities.get_user_by_session_token(token)
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = insert(:user)
      email = insert(:email, user: user)
      client_service = insert(:client_service)

      token =
        extract_user_token(fn url ->
          Identities.deliver_user_reset_password_instructions(email, url, client_service.id)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{token: token} do
      assert {:ok, _client_service, user} = Identities.get_user_by_reset_password_token(token)

      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Identities.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Identities.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      user = insert(:user)
      email = insert(:email, user: user, primary: true)

      %{user: user, email: email}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Identities.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Identities.reset_user_password(user, %{password: too_long})
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user, email: email} do
      {:ok, updated_user} =
        Identities.reset_user_password(user, %{password: "new valid password"})

      assert is_nil(updated_user.password)

      assert Identities.get_user_by_email_and_password(
               email.address,
               "new valid password"
             )
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Identities.generate_user_session_token(user)
      {:ok, _} = Identities.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      user = insert(:user)
      email = insert(:email, user: user, primary: true)
      %{email: email, user: user}
    end

    test "sends token through notification", %{user: user, email: email} do
      client_service = insert(:client_service)

      token =
        extract_user_token(fn url ->
          Identities.deliver_user_reset_password_instructions(email, url, client_service.id)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == email.address
      assert user_token.context == "reset_password"
    end
  end
end
