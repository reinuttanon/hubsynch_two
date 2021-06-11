defmodule HubIdentityWeb.Api.V1.VerificationControllerTest do
  use HubIdentityWeb.ConnCase, async: true

  import HubIdentity.Factory

  alias HubIdentity.{MementoRepo, Metrics}
  alias HubIdentity.Verifications.VerificationCode

  setup :build_api_conn

  describe "create/2" do
    test "with a valid user uid and reference sends 201 response", %{
      conn: conn,
      user: user
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      new_conn =
        conn
        |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})

      assert response(new_conn, 201) =~ "successful operation"
    end

    test "with an invalid user uid returns user not found", %{
      conn: conn
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      error =
        conn
        |> post("/api/v1/users/555_nooupe/verification", %{reference: reference})
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "with a bad reference returns error message", %{
      conn: conn,
      user: user
    } do
      error =
        conn
        |> post("/api/v1/users/#{user.uid}/verification", %{reference: "tooshort"})
        |> json_response(400)

      assert error == %{"error" => "invalid reference should be between 22 and 44 characters"}
    end
  end

  describe "validate/2" do
    test "with valid code, user, and reference returns success response", %{
      conn: conn,
      user: user
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      conn
      |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})
      |> response(201)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, reference}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      response =
        conn
        |> put("/api/v1/users/#{user.uid}/verification/validate", %{
          reference: reference,
          code: code
        })
        |> json_response(200)

      assert response == %{"ok" => "verification success"}
    end

    test "with valid code, user, and reference creates a metric", %{
      conn: conn,
      user: user
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
      assert Metrics.list_user_activities() == []

      conn
      |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})
      |> response(201)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, reference}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      conn
      |> put("/api/v1/users/#{user.uid}/verification/validate", %{
        reference: reference,
        code: code
      })
      |> json_response(200)

      user_activity = Metrics.list_user_activities() |> hd()

      assert user_activity.owner_type == "User"
      assert user_activity.owner_uid != nil
      assert user_activity.provider == "self"
      assert user_activity.type == "Verification.success"
    end

    test "with invalid user returns user not found", %{
      conn: conn
    } do
      error =
        conn
        |> put("/api/v1/users/555_nooupe/verification/validate", %{
          reference: "reference",
          code: "code"
        })
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "with invalid reference returns error", %{
      conn: conn,
      user: user
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      conn
      |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})
      |> response(201)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, reference}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      error =
        conn
        |> put("/api/v1/users/#{user.uid}/verification/validate", %{
          reference: "wrong_reference_here_yo",
          code: code
        })
        |> json_response(400)

      assert error == %{"error" => "verification failed"}
    end

    test "with the wrong code returns error", %{
      conn: conn,
      user: user
    } do
      reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      conn
      |> post("/api/v1/users/#{user.uid}/verification", %{reference: reference})
      |> response(201)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, reference}
      ]

      assert {:ok, [%VerificationCode{code: code}]} = MementoRepo.get(VerificationCode, query)

      wrong_code = generate_new_code(code)

      error =
        conn
        |> put("/api/v1/users/#{user.uid}/verification/validate", %{
          reference: reference,
          code: wrong_code
        })
        |> json_response(400)

      assert error == %{"error" => "verification failed"}
    end
  end

  describe "renew/2" do
    test "with a valid user uid, old reference and new reference sends 201 response", %{
      conn: conn,
      user: user
    } do
      old_reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
      new_reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      conn
      |> post("/api/v1/users/#{user.uid}/verification", %{reference: old_reference})
      |> response(201)

      query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, old_reference}
      ]

      assert {:ok, [%VerificationCode{reference: ^old_reference}]} =
               MementoRepo.get(VerificationCode, query)

      new_conn =
        conn
        |> post("/api/v1/users/#{user.uid}/verification/renew", %{
          old_reference: old_reference,
          new_reference: new_reference
        })

      assert response(new_conn, 201) =~ "successful operation"

      assert {:ok, []} = MementoRepo.get(VerificationCode, query)

      new_query = [
        {:==, :user_uid, user.uid},
        {:==, :reference, new_reference}
      ]

      assert {:ok, [%VerificationCode{reference: ^new_reference}]} =
               MementoRepo.get(VerificationCode, new_query)
    end

    test "with an invalid user uid returns user not found", %{
      conn: conn
    } do
      old_reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
      new_reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      error =
        conn
        |> post("/api/v1/users/555_nooupe/verification/renew", %{
          old_reference: old_reference,
          new_reference: new_reference
        })
        |> json_response(400)

      assert error == %{"error" => "User not found"}
    end

    test "with a bad new reference returns error message", %{
      conn: conn,
      user: user
    } do
      old_reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

      error =
        conn
        |> post("/api/v1/users/#{user.uid}/verification/renew", %{
          old_reference: old_reference,
          new_reference: "tooshort"
        })
        |> json_response(400)

      assert error == %{"error" => "invalid reference should be between 22 and 44 characters"}
    end
  end

  defp build_api_conn(_) do
    client_service = insert(:client_service)
    api_key = insert(:api_key, type: "private", client_service: client_service)
    user = insert(:user)
    insert(:confirmed_email, user: user)

    conn =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> put_req_header("x-api-key", api_key.data)

    {:ok, %{conn: conn, client_service: client_service, user: user}}
  end

  defp generate_new_code(code) do
    new_code = Enum.random(1_000..9_999)

    case new_code == code do
      true -> generate_new_code(code)
      false -> new_code
    end
  end
end
