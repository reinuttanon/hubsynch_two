defmodule HubIdentityWeb.Api.V1.EmailControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  import HubIdentity.Factory

  alias HubCluster.MementoRepo
  alias HubIdentity.Verifications.EmailVerifyReferenceServer
  alias HubIdentity.Verifications.VerificationCode
  alias HubIdentity.Identities

  setup do
    user = insert(:user)
    email = insert(:email, user: user)
    %{email: email, user: user}
  end

  describe "index/2" do
    test "returns all the emails for the user", %{user: user, email: email} do
      email_two = insert(:email, user: user)
      email_three = insert(:email, user: user)

      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.uid}/emails")
        |> json_response(200)

      assert length(response) == 3

      assert Enum.any?(response, fn e -> e["uid"] == email.uid end)
      assert Enum.any?(response, fn e -> e["uid"] == email_two.uid end)
      assert Enum.any?(response, fn e -> e["uid"] == email_three.uid end)
    end

    test "returns error if the user does not exist" do
      error =
        build_api_conn()
        |> get("/api/v1/users/555nooupe/emails")

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "show/2" do
    test "returns the email if the uid is valid", %{email: email, user: user} do
      response =
        build_api_conn()
        |> get("/api/v1/users/#{user.uid}/emails/#{email.uid}")
        |> json_response(200)

      assert response["Object"] == "Email"
      assert response["address"] == email.address
      assert response["confirmed_at"] == email.confirmed_at
      assert response["primary"] == email.primary
      assert response["uid"] == email.uid
    end

    test "returns error if the email uid is invalid", %{user: user} do
      error =
        build_api_conn()
        |> get("/api/v1/users/#{user.uid}/emails/555nooupe")

      assert response(error, 400) =~ "bad request"
    end

    test "returns error if the user uid is invalid", %{email: email} do
      error =
        build_api_conn()
        |> get("/api/v1/users/555nooupe/emails/#{email.uid}")

      assert response(error, 400) =~ "bad request"
    end

    test "returns error if the email owner does not match the user uid", %{user: user} do
      email = insert(:email)
      assert email.user_id != user.id

      error =
        build_api_conn()
        |> get("/api/v1/users/#{user.uid}/emails/#{email.uid}")

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "create/2" do
    test "with valid params returns the success message", %{user: user} do
      response =
        build_api_conn()
        |> post(
          "/api/v1/users/#{user.uid}/emails",
          email: %{address: "erin@hivelocity.co.jp"}
        )

      assert response(response, 201) =~ "request sent"
    end

    test "with invalid email address returns the error message", %{user: user} do
      response =
        build_api_conn()
        |> post(
          "/api/v1/users/#{user.uid}/emails",
          email: %{address: "bad_email"}
        )
        |> json_response(400)

      assert response["error"]["address"] == ["must have the @ sign and no spaces"]
    end

    test "with existing email address returns the error message", %{user: user} do
      email = insert(:email)

      response =
        build_api_conn()
        |> post(
          "/api/v1/users/#{user.uid}/emails",
          email: %{address: email.address}
        )
        |> json_response(400)

      assert response["error"]["address"] == ["has already been taken"]
    end
  end

  describe "resend_confirmation/2" do
    test "with valid params returns the success message", %{user: user} do
      client_service = insert(:client_service)

      api_key = insert(:api_key, type: "private", client_service: client_service)

      conn =
        build_conn()
        |> put_req_header("accept", "application/json")
        |> put_req_header("x-api-key", api_key.data)

      attrs = %{
        address: "erin@hivelocity.co.jp",
        client_service_uid: client_service.uid,
        user: user,
        redirect_url: client_service.redirect_url
      }

      EmailVerifyReferenceServer.create_reference(attrs)

      response =
        conn
        |> get(
          "/api/v1/users/emails/resend_confirmation",
          %{address: "erin@hivelocity.co.jp"}
        )

      assert response(response, 201) =~ "request sent"
    end

    test "with invalid email returns error message" do
      error =
        build_api_conn()
        |> get(
          "/api/v1/users/emails/resend_confirmation",
          %{address: "invalid_email"}
        )

      assert response(error, 400) =~ "bad request"
    end

    test "with unexisting reference returns error message" do
      error =
        build_api_conn()
        |> get(
          "/api/v1/users/emails/resend_confirmation",
          %{address: "erin@hivelocity.co.jp"}
        )

      assert response(error, 400) =~ "bad request"
    end
  end

  describe "change_primary_email/2" do
    setup do
      user = insert(:user)
      email = insert(:email, user: user, confirmed_at: DateTime.utc_now(), primary: true)
      conn = build_api_conn()
      %{user: user, email: email, conn: conn}
    end

    test "with a confirmed email sets to primary", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      new_primary_email = insert(:email, user: user, confirmed_at: DateTime.utc_now())

      {:ok, current_primary} =
        Identities.get_user!(user.id, preload: true) |> Identities.get_user_primary_email()

      assert current_primary.uid == email.uid

      response =
        conn
        |> put(
          "/api/v1/users/#{user.uid}/emails/change_primary_email/#{new_primary_email.uid}",
          %{reference: reference, code: code}
        )
        |> json_response(200)

      assert response["Object"] == "Email"
      assert response["address"] == new_primary_email.address
      assert response["primary"] == true
      assert response["uid"] == new_primary_email.uid

      {:ok, new_primary} =
        Identities.get_user!(user.id, preload: true) |> Identities.get_user_primary_email()

      assert new_primary.uid == new_primary_email.uid
    end

    test "with a users primary email returns the email", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      response =
        conn
        |> put("/api/v1/users/#{user.uid}/emails/change_primary_email/#{email.uid}", %{
          reference: reference,
          code: code
        })
        |> json_response(200)

      assert response["Object"] == "Email"
      assert response["address"] == email.address
      assert response["primary"] == true
      assert response["uid"] == email.uid
    end

    test "with an unconfirmed email returns error", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      unconfirmed_email = insert(:email, user: user, confirmed_at: nil)

      {:ok, current_primary} =
        Identities.get_user!(user.id, preload: true) |> Identities.get_user_primary_email()

      assert current_primary.uid == email.uid

      response =
        conn
        |> put(
          "/api/v1/users/#{user.uid}/emails/change_primary_email/#{unconfirmed_email.uid}",
          %{reference: reference, code: code}
        )
        |> json_response(400)

      assert response["error"]["confirmation"] == ["email must be confirmed"]

      {:ok, same_primary} =
        Identities.get_user!(user.id, preload: true) |> Identities.get_user_primary_email()

      assert same_primary.uid == email.uid
    end

    test "with different users email returns error", %{user: user, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      different_user_email = insert(:email)
      assert different_user_email.user_id != user.id

      error =
        conn
        |> put(
          "/api/v1/users/#{user.uid}/emails/change_primary_email/#{different_user_email.uid}",
          %{reference: reference, code: code}
        )

      assert response(error, 400) =~ "bad request"
    end

    test "returns error with an invalid user uid", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> put("/api/v1/users/555nooupe/emails/change_primary_email/#{email.uid}", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "bad request"
    end

    test "returns error with an invalid email uid", %{user: user, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> put("/api/v1/users/#{user.uid}/emails/change_primary_email/555nooupe}", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "bad request"
    end

    test "returns error with an invalid code or reference", %{
      user: user,
      email: email,
      conn: conn
    } do
      new_primary_email = insert(:email, user: user, confirmed_at: DateTime.utc_now())

      {:ok, current_primary} =
        Identities.get_user!(user.id, preload: true) |> Identities.get_user_primary_email()

      assert current_primary.uid == email.uid

      error =
        conn
        |> put(
          "/api/v1/users/#{user.uid}/emails/change_primary_email/#{new_primary_email.uid}",
          %{reference: "invalid_reference", code: "invalid_code"}
        )

      assert response(error, 400) =~ "verification failed"
    end
  end

  describe "delete/2" do
    setup do
      user = insert(:user)
      primary_email = insert(:email, user: user, address: "primary@gmail.com", primary: true)
      email = insert(:email, user: user)
      conn = build_api_conn()
      %{user: user, primary_email: primary_email, email: email, conn: conn}
    end

    test "with valid user and email returns ok response", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      response =
        conn
        |> delete("/api/v1/users/#{user.uid}/emails/#{email.uid}", %{
          reference: reference,
          code: code
        })
        |> json_response(201)

      assert response == %{"success" => "email #{email.uid} deleted"}

      assert_raise Ecto.NoResultsError, fn ->
        Identities.get_email!(email.id)
      end
    end

    test "returns error if primary email", %{user: user, primary_email: primary_email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> delete("/api/v1/users/#{user.uid}/emails/#{primary_email.uid}", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "Not allowed to delete primary email"
    end

    test "returns error if a different user email", %{user: user, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      different_user_email = insert(:email)
      assert different_user_email.user_id != user.id

      error =
        conn
        |> delete("/api/v1/users/#{user.uid}/emails/#{different_user_email.uid}", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "bad request"
    end

    test "returns error with an invalid email uid", %{user: user, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> delete("/api/v1/users/#{user.uid}/emails/555nooupe", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "bad request"
    end

    test "returns error with an invalid user uid", %{user: user, email: email, conn: conn} do
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> delete("/api/v1/users/555nooupe/emails/#{email.uid}", %{
          reference: reference,
          code: code
        })

      assert response(error, 400) =~ "bad request"
    end

    test "with invalid refernce and code returns error response", %{
      user: user,
      email: email,
      conn: conn
    } do
      error =
        conn
        |> delete("/api/v1/users/#{user.uid}/emails/#{email.uid}", %{
          reference: "invalid_reference",
          code: "invalid_code"
        })

      assert response(error, 400) =~ "verification failed"
    end
  end

  defp build_api_conn(type \\ "private") do
    api_key = insert(:api_key, type: type)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end

  defp generate_validation_code(user, conn) do
    reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

    conn
    |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})
    |> response(201)

    query = [
      {:==, :user_uid, user.uid},
      {:==, :reference, reference}
    ]

    {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

    %{reference: reference, code: code}
  end
end
