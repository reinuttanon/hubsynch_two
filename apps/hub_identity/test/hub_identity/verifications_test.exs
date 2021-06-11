defmodule HubIdentity.VerificationsTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.{Identities, MementoRepo, Verifications}
  alias HubIdentity.Verifications.{EmailVerifyReference, VerificationCode}

  describe "create_email_verify_reference/1" do
    setup do
      client_service = insert(:client_service, redirect_url: "redirect/url/here")

      %{client_service: client_service}
    end

    test "with a valid email and user changesets returns ok and a reference", %{
      client_service: client_service
    } do
      {:ok, %EmailVerifyReference{reference: reference}} =
        Verifications.create_email_verify_reference(
          %{
            address: "erin@hivelocity.co.jp",
            password: "LongPassword!"
          },
          client_service
        )

      email_verify_reference = MementoRepo.all(EmailVerifyReference) |> hd()

      assert email_verify_reference.id != nil
      assert email_verify_reference.address == "erin@hivelocity.co.jp"
      assert email_verify_reference.expires_at != nil
      assert email_verify_reference.redirect_url == "redirect/url/here"
      assert email_verify_reference.reference == reference
      assert email_verify_reference.user.valid?
    end

    test "with a valid email address and provider returns ok and a reference ", %{
      client_service: client_service
    } do
      {:ok, %EmailVerifyReference{reference: reference}} =
        Verifications.create_email_verify_reference(
          %{
            address: "email@gmail.com",
            provider_info: "facebook"
          },
          client_service
        )

      email_verify_reference = MementoRepo.all(EmailVerifyReference) |> hd()

      assert email_verify_reference.id != nil
      assert email_verify_reference.address == "email@gmail.com"
      assert email_verify_reference.expires_at != nil
      assert email_verify_reference.provider_info == "facebook"
      assert email_verify_reference.redirect_url == "redirect/url/here"
      assert email_verify_reference.reference == reference
    end

    test "with invalid email address returns error changeset ", %{
      client_service: client_service
    } do
      assert {:error, changeset} =
               Verifications.create_email_verify_reference(
                 %{address: "", password: "LongPassword"},
                 client_service
               )

      refute changeset.valid?
      assert changeset.errors[:address] == {"can't be blank", [validation: :required]}
    end

    test "returns error with changeset with invalid password", %{client_service: client_service} do
      assert {:error, changeset} =
               Verifications.create_email_verify_reference(
                 %{
                   address: "email@gmail.com",
                   password: "pass"
                 },
                 client_service
               )

      refute changeset.valid?

      assert changeset.errors[:password] ==
               {"should be at least %{count} character(s)",
                [{:count, 12}, {:validation, :length}, {:kind, :min}, {:type, :string}]}
    end

    test "with a valid email and user_id returns ok and a reference", %{
      client_service: client_service
    } do
      user = insert(:user)

      {:ok, %EmailVerifyReference{reference: reference}} =
        Verifications.create_email_verify_reference(
          %{
            address: "erin@hivelocity.co.jp",
            user: %{user_id: user.id}
          },
          client_service
        )

      email_verify_reference = MementoRepo.all(EmailVerifyReference) |> hd()

      assert email_verify_reference.id != nil
      assert email_verify_reference.address == "erin@hivelocity.co.jp"
      assert email_verify_reference.expires_at != nil
      assert email_verify_reference.redirect_url == "redirect/url/here"
      assert email_verify_reference.reference == reference
      assert email_verify_reference.user == %{user_id: user.id}
    end

    test "with a invalid email returns error and changeset", %{
      client_service: client_service
    } do
      user = insert(:user)

      assert {:error, changeset} =
               Verifications.create_email_verify_reference(
                 %{
                   address: "bad_email",
                   user: %{user_id: user.id}
                 },
                 client_service
               )

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"must have the @ sign and no spaces", [validation: :format]}
    end

    test "with an email already exist returns error and changeset", %{
      client_service: client_service
    } do
      user = insert(:user)
      email = insert(:email)

      assert {:error, changeset} =
               Verifications.create_email_verify_reference(
                 %{
                   address: email.address,
                   user: %{user_id: user.id}
                 },
                 client_service
               )

      refute changeset.valid?

      assert changeset.errors[:address] ==
               {"has already been taken", [{:validation, :unsafe_unique}, {:fields, [:address]}]}
    end
  end

  describe "delete_code/3" do
    test "with valid user, client_service, and reference deletes the verification_code" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      {:ok, [verification_code]} =
        MementoRepo.get(VerificationCode, [{:==, :user_uid, loaded_user.uid}])

      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference

      assert :ok ==
               Verifications.delete_code(loaded_user, client_service, reference)

      assert [] == MementoRepo.all(VerificationCode)
    end

    test "with wrong user returns ok and does not delete the valid code" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      {:ok, [verification_code]} =
        MementoRepo.get(VerificationCode, [{:==, :user_uid, loaded_user.uid}])

      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference

      different_user = insert(:user)

      assert :ok ==
               Verifications.delete_code(different_user, client_service, reference)

      assert verification_code == MementoRepo.all(VerificationCode) |> hd()
    end

    test "with wrong client_service returns ok and does not delete the valid code" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      {:ok, [verification_code]} = MementoRepo.get(VerificationCode, [{:==, :user_uid, user.uid}])

      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference

      different_client_service = insert(:client_service)

      assert :ok ==
               Verifications.delete_code(loaded_user, different_client_service, reference)

      assert {:ok, [^verification_code]} =
               MementoRepo.get(VerificationCode, [{:==, :user_uid, user.uid}])
    end

    test "with wrong reference returns ok and does not delete the valid code" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      {:ok, [verification_code]} =
        MementoRepo.get(VerificationCode, [{:==, :user_uid, loaded_user.uid}])

      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference

      assert :ok ==
               Verifications.delete_code(loaded_user, client_service, "bad_reference")

      assert {:ok, [^verification_code]} =
               MementoRepo.get(VerificationCode, [{:==, :user_uid, loaded_user.uid}])
    end
  end

  describe "generate_code/2" do
    test "with valid reference generates and save a verification code" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      assert MementoRepo.all(VerificationCode) == []

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      verification_code = MementoRepo.all(VerificationCode) |> hd()
      assert verification_code.code != nil
      assert verification_code.user_uid == user.uid
      assert verification_code.client_service_uid == client_service.uid
      assert verification_code.reference == reference
      assert verification_code.attempts == 0
    end

    test "with invalid size reference returns error" do
      user = insert(:user)
      client_service = insert(:client_service)

      assert {:error, "invalid reference should be between 22 and 44 characters"} =
               Verifications.generate_code(user, client_service, "tooshort")
    end

    test "returns error if reference is not unique" do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      assert {:ok, []} == MementoRepo.get(VerificationCode, [{:==, :reference, reference}])

      loaded_user = Identities.get_user(%{uid: user.uid})

      assert :ok == Verifications.generate_code(loaded_user, client_service, reference)

      assert {:error, "reference must be unique"} ==
               Verifications.generate_code(loaded_user, client_service, reference)
    end
  end

  describe "validate_code/3" do
    setup do
      user = insert(:user)
      insert(:confirmed_email, user: user)
      client_service = insert(:client_service)
      full_user = Identities.get_user(%{uid: user.uid})
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
      %{client_service: client_service, user: full_user, reference: reference}
    end

    test "with a valid code, user, and client server returns ok", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      for _ <- 1..5 do
        different_user = insert(:user)
        insert(:email, user: different_user, primary: true)
        different_client_service = insert(:client_service)
        full_different_user = Identities.get_user(%{uid: different_user.uid})

        assert :ok =
                 Verifications.generate_code(
                   full_different_user,
                   different_client_service,
                   reference
                 )
      end

      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      assert {:ok, "verification success"} ==
               Verifications.validate_code(code, user, client_service, reference)

      assert {:ok, []} == MementoRepo.get(VerificationCode, query)
    end

    test "with a invalid code returns error", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{attempts: attempts}]} =
               MementoRepo.get(VerificationCode, query)

      assert attempts == 0

      wrongs = ["wrong", [1, 2, 3, 4], %{a: "b"}]

      for wrong <- wrongs do
        assert {:error, _} = Verifications.validate_code(wrong, user, client_service, reference)
      end
    end

    test "with a wrong code returns error", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code, attempts: attempts}]} =
               MementoRepo.get(VerificationCode, query)

      assert attempts == 0

      wrong_code = generate_new_code(code)

      assert {:error, "verification failed"} ==
               Verifications.validate_code(wrong_code, user, client_service, reference)

      assert {:ok, [%VerificationCode{attempts: new_attempts}]} =
               MementoRepo.get(VerificationCode, query)

      assert new_attempts == 1
    end

    test "with an wrong user returns error", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code} = verification]} =
               MementoRepo.get(VerificationCode, query)

      wrong_user = insert(:user)

      assert {:error, "verification failed"} ==
               Verifications.validate_code(code, wrong_user, client_service, reference)

      assert {:ok, [verification]} == MementoRepo.get(VerificationCode, query)
    end

    test "with a wrong client service returns error", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code} = verification]} =
               MementoRepo.get(VerificationCode, query)

      wrong_client_service = insert(:client_service)

      assert {:error, "verification failed"} ==
               Verifications.validate_code(code, user, wrong_client_service, reference)

      assert {:ok, [verification]} == MementoRepo.get(VerificationCode, query)
    end

    test "after 3 attempts deletes the verification code and returns error", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      attempts =
        for _ <- 1..3 do
          wrong = generate_new_code(code)
          Verifications.validate_code(wrong, user, client_service, reference)
        end

      assert attempts == [
               error: "verification failed",
               error: "verification failed",
               error: "max attempts reached"
             ]

      assert {:ok, []} = MementoRepo.get(VerificationCode, query)
    end

    test "the 3rd attempt is still available if the code is valid", %{
      client_service: client_service,
      user: user,
      reference: reference
    } do
      assert :ok = Verifications.generate_code(user, client_service, reference)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :client_service_uid, client_service.uid}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      attempts =
        for _ <- 1..2 do
          wrong = generate_new_code(code)
          Verifications.validate_code(wrong, user, client_service, reference)
        end

      assert attempts == [
               error: "verification failed",
               error: "verification failed"
             ]

      assert {:ok, "verification success"} =
               Verifications.validate_code(code, user, client_service, reference)
    end

    defp generate_new_code(code) do
      new_code = Enum.random(1_000..9_999)

      case new_code == code do
        true -> generate_new_code(code)
        false -> new_code
      end
    end
  end

  describe "withdraw_verify_email_reference/1" do
    setup do
      client_service = insert(:client_service)
      %{client_service: client_service}
    end

    test "with the correct reference deletes the email_verify_reference", %{
      client_service: client_service
    } do
      {:ok, %EmailVerifyReference{reference: reference} = email_verify_reference} =
        Verifications.create_email_verify_reference(
          %{
            address: "erin@hivelocity.co.jp",
            password: "LongPassword!"
          },
          client_service
        )

      assert MementoRepo.all(EmailVerifyReference) == [email_verify_reference]

      assert {:ok, _email_verify_reference} =
               Verifications.withdraw_verify_email_reference(reference)

      assert MementoRepo.all(EmailVerifyReference) == []
    end

    test "with provider_info updates the email_verified to true", %{
      client_service: client_service
    } do
      provider_info = %{
        details: %{"email" => "sullymustycode@gmail.com", "id" => "12345"},
        email: "sullymustycode@gmail.com",
        email_verified: false,
        provider: "facebook",
        provider_config_id: 20542,
        reference: "12345"
      }

      {:ok, %EmailVerifyReference{reference: reference}} =
        Verifications.create_email_verify_reference(
          %{
            address: "erin@hivelocity.co.jp",
            provider_info: provider_info
          },
          client_service
        )

      assert {:ok, %EmailVerifyReference{provider_info: provider_info}} =
               Verifications.withdraw_verify_email_reference(reference)

      assert provider_info.email_verified
    end

    test "with invalid email doesn't delete the email_verify_reference", %{
      client_service: client_service
    } do
      {:ok, %EmailVerifyReference{} = email_verify_reference} =
        Verifications.create_email_verify_reference(
          %{
            address: "erin@hivelocity.co.jp",
            password: "LongPassword!"
          },
          client_service
        )

      assert MementoRepo.all(EmailVerifyReference) == [email_verify_reference]

      assert {:error, "Elixir.HubIdentity.Verifications.EmailVerifyReference not found"} =
               Verifications.withdraw_verify_email_reference("something_totally_different")

      assert MementoRepo.all(EmailVerifyReference) == [email_verify_reference]
    end
  end
end
