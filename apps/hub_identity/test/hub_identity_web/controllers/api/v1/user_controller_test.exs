defmodule HubIdentityWeb.Api.V1.UserControllerTest do
  use HubIdentityWeb.ConnCase

  import HubIdentity.Factory

  alias HubCluster.MementoRepo
  alias HubIdentity.{Identities, Metrics}
  alias HubIdentity.Verifications.EmailVerifyReference
  alias HubIdentityWeb.Authentication.AccessCookiesServer
  alias HubIdentity.Verifications.VerificationCode

  describe "public key routes" do
    setup do
      MementoRepo.clear(EmailVerifyReference)
      :ok
    end

    test "create/2 creates a new user with valid params" do
      %{api_key: api_key} = create_client_service("public")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erinp+1@hivelocity.co.jp",
            password: "LongPassword"
          }
        )
        |> json_response(200)

      assert response["ok"] == "email verification request sent"
    end

    test "create/2 creates a user email verify reference" do
      %{api_key: api_key} = create_client_service("public")

      build_api_conn(api_key.data)
      |> post("/api/v1/users",
        user: %{
          email: "erinp+1@hivelocity.co.jp",
          password: "LongPassword"
        }
      )
      |> json_response(200)

      assert {:ok, [email_verify]} =
               MementoRepo.get(EmailVerifyReference, [{:==, :address, "erinp+1@hivelocity.co.jp"}])

      assert email_verify.address == "erinp+1@hivelocity.co.jp"
    end

    test "create/2 with invalid email returns response with errors" do
      %{api_key: api_key} = create_client_service("public")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erinp",
            password: "LongPassword"
          }
        )
        |> json_response(400)

      assert response["error"] == %{"address" => ["must have the @ sign and no spaces"]}
    end

    test "create/2 with existing email returns response with errors" do
      %{api_key: api_key} = create_client_service("public")
      insert(:email, address: "erin@hivelocity.co.jp")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erin@hivelocity.co.jp",
            password: "LongPassword"
          }
        )
        |> json_response(400)

      assert response["error"] == %{"address" => ["has already been taken"]}
    end

    test "create/2 with invalid passwrod returns response with errors" do
      %{api_key: api_key} = create_client_service("public")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erin@hivelocity.co.jp",
            password: "bad"
          }
        )
        |> json_response(400)

      assert response["error"] == %{"password" => ["should be at least 12 character(s)"]}
    end

    test "create/2 with invalid params returns bad request response with errors" do
      %{api_key: api_key} = create_client_service("public")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erinp+1@hivelocity.co.jp"
          }
        )
        |> json_response(400)

      assert response["error"] == "bad request"
    end

    test "create/2 with private key returns bad request response" do
      %{api_key: api_key} = create_client_service("private")

      conn =
        build_api_conn(api_key.data)
        |> post("/api/v1/users",
          user: %{
            email: "erinp+1@hivelocity.co.jp",
            password: "password"
          }
        )

      assert response(conn, 401) =~ "not authorized"
    end

    test "reset_password/2 returns 204 successful with valid email" do
      %{api_key: api_key, email: email} = create_client_service("public")

      conn =
        build_api_conn(api_key.data)
        |> post("/api/v1/users/reset_password", %{email: email.address})

      assert response(conn, 201) =~ "request sent"
    end

    test "reset_password/2 creates a user reset password token" do
      %{api_key: api_key, email: email, user: user} = create_client_service("public")

      build_api_conn(api_key.data)
      |> post("/api/v1/users/reset_password", %{
        email: email.address
      })

      assert HubIdentity.Repo.get_by!(Identities.UserToken, user_id: user.id).context ==
               "reset_password"
    end
  end

  describe "private key routes" do
    test "authenticate/2 with correct email and password returns the current user" do
      %{api_key: api_key, user: user, email: email} = create_client_service("private")

      response =
        build_api_conn(api_key.data)
        |> post("/api/v1/users/authenticate", %{
          email: email.address,
          password: valid_user_password()
        })
        |> json_response(200)

      assert response["Object"] == "CurrentUser"
      assert response["authenticated_at"] != nil
      assert response["authenticated_by"] == "HubIdentity"
      assert response["email"] == email.address
      assert response["uid"] == user.uid
    end

    test "authenticate/2 with correct email and password creates a cookie metric" do
      %{api_key: api_key, client_service: client_service, email: email, user: user} =
        create_client_service("private")

      assert Metrics.list_user_activities() == []

      build_api_conn(api_key.data)
      |> post("/api/v1/users/authenticate", %{
        email: email.address,
        password: valid_user_password()
      })
      |> json_response(200)

      metric = Metrics.list_user_activities() |> hd()
      assert metric.client_service_uid == client_service.uid
      assert metric.owner_type == "User"
      assert metric.owner_uid == user.uid
      assert metric.provider == "self"
      assert metric.type == "AccessCookie.create"
    end

    test "authenticate/2 with wrong password returns error" do
      %{api_key: api_key, email: email} = create_client_service("private")

      error =
        build_api_conn(api_key.data)
        |> post("/api/v1/users/authenticate", %{
          email: email.address,
          password: "lanaaaa-nooupe!"
        })
        |> response(400)

      assert error =~ "bad request"
    end

    test "authenticate/2 with wrong email returns error" do
      %{api_key: api_key} = create_client_service("private")

      error =
        build_api_conn(api_key.data)
        |> post("/api/v1/users/authenticate", %{
          email: "nope@aol.com",
          password: valid_user_password()
        })
        |> response(400)

      assert error =~ "bad request"
    end

    test "authenticate/2 with no password returns error" do
      %{api_key: api_key, email: email} = create_client_service("private")

      error =
        build_api_conn(api_key.data)
        |> post("/api/v1/users/authenticate", %{
          email: email.address
        })
        |> response(400)

      assert error =~ "bad request"
    end

    test "show/2 returns the found user by uid" do
      %{api_key: api_key, user: user, email: email} = create_client_service("private")

      response =
        build_api_conn(api_key.data)
        |> get("/api/v1/users/#{user.uid}")
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["uid"] == user.uid
      assert Enum.any?(response["emails"], fn e -> e["address"] == email.address end)
    end

    test "show/2 returns the found user by email" do
      %{api_key: api_key, email: email, user: user} = create_client_service("private")

      response =
        build_api_conn(api_key.data)
        |> get("/api/v1/users?email=#{email.address}")
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["uid"] == user.uid
      assert Enum.any?(response["emails"], fn e -> e["address"] == email.address end)
    end

    test "show/2 returns the found user by email with +" do
      %{api_key: api_key, user: user} = create_client_service("private")

      email = insert(:email, address: "sully+1@gmail.com", user: user)

      response =
        build_api_conn(api_key.data)
        |> get("/api/v1/users?email=#{email.address}")
        |> json_response(200)

      assert response["Object"] == "User"
      assert response["uid"] == user.uid

      assert Enum.any?(response["emails"], fn email -> email["address"] == "sully+1@gmail.com" end)
    end

    test "show/2 returns bad request if no user with uid" do
      %{api_key: api_key} = create_client_service("private")

      error =
        build_api_conn(api_key.data)
        |> get("/api/v1/users/555")
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "show/2 returns bad request if no user with email" do
      %{api_key: api_key} = create_client_service("private")

      error =
        build_api_conn(api_key.data)
        |> get("/api/v1/users?email=notuser@fail.co")
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "show/2 returns not authorized if public key" do
      %{api_key: api_key, user: user} = create_client_service("public")

      error =
        build_api_conn(api_key.data)
        |> get("/api/v1/users/#{user.uid}")
        |> response(401)

      assert error == "not authorized"
    end

    test "delete/2 returns 204 success with a valid user" do
      %{api_key: api_key, user: user} = create_client_service("private")

      conn = build_api_conn(api_key.data)
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      message =
        conn
        |> delete("/api/v1/users/#{user.uid}", %{reference: reference, code: code})
        |> response(202)

      assert message =~ "successful operation"
    end

    test "delete/2 wih a valid user deletes all the cookies" do
      %{api_key: api_key, user: user} = create_client_service("private")

      conn = build_api_conn(api_key.data)
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      assert {:ok, _cookie} = AccessCookiesServer.create_cookie(user)
      assert {:ok, _cookie} = AccessCookiesServer.create_cookie(user)

      cookies = AccessCookiesServer.get_cookies(%{uid: user.uid})
      assert length(cookies) == 2

      message =
        conn
        |> delete("/api/v1/users/#{user.uid}", %{reference: reference, code: code})
        |> response(202)

      assert message =~ "successful operation"

      assert [] == AccessCookiesServer.get_cookies(%{uid: user.uid})
    end

    test "delete/2 with a valid user generates a user_activity" do
      %{api_key: api_key, user: user, client_service: client_service} =
        create_client_service("private")

      conn = build_api_conn(api_key.data)
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      assert Metrics.list_user_activities() == []

      conn
      |> delete("/api/v1/users/#{user.uid}", %{reference: reference, code: code})
      |> response(202)

      user_activity = Metrics.list_user_activities() |> hd()

      assert user_activity.client_service_uid == client_service.uid
      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid == user.uid
      assert user_activity.provider == "self"
      assert user_activity.type == "User.delete"
      assert user_activity.remote_address != nil
    end

    test "delete/2 returns bad request if no user" do
      %{api_key: api_key, user: user} = create_client_service("private")

      conn = build_api_conn(api_key.data)
      %{reference: reference, code: code} = generate_validation_code(user, conn)

      error =
        conn
        |> delete("/api/v1/users/555", %{reference: reference, code: code})
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "delete/2 returns not authorized if public key" do
      %{api_key: api_key, user: user} = create_client_service("public")

      error =
        build_api_conn(api_key.data)
        |> delete("/api/v1/users/#{user.uid}", %{reference: "reference", code: "code"})
        |> response(401)

      assert error == "not authorized"
    end

    test "delete/2 returns error with a invalid reference and code" do
      %{api_key: api_key, user: user} = create_client_service("private")

      conn = build_api_conn(api_key.data)

      error =
        conn
        |> delete("/api/v1/users/#{user.uid}", %{
          reference: "invalid_reference",
          code: "invalid_code"
        })

      assert response(error, 400) =~ "verification failed"
    end
  end

  defp build_api_conn(api_key) do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key)
  end

  defp create_client_service(type) do
    client_service = insert(:client_service)
    api_key = insert(:api_key, type: type, client_service: client_service)
    user = insert(:user)
    email = insert(:confirmed_email, user: user)
    %{client_service: client_service, api_key: api_key, user: user, email: email}
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
