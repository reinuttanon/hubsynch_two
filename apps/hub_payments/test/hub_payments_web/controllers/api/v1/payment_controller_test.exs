defmodule HubPaymentsWeb.Api.V1.PaymentControllerTest do
  use HubPaymentsWeb.ConnCase

  alias HubPayments.{Wallets, Payments, Providers}

  describe "process/2" do
    test "charge payment with valid data returns success and charge uuid" do
      response =
        build_api_conn()
        |> post("/api/v1/payments/process", charge_token_body())
        |> json_response(200)

      assert response["amount"] == 34567
      assert response["charge_uuid"] != nil
      assert response["currency"] == "JPY"
      assert response["result"] == "Payment successful"
    end

    test "with nil amount returns error" do
      charge = %{charge_token_body().charge | amount: nil}

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{provider: "paygent", charge: charge})
        |> json_response(400)

      assert response["error"]["money"] == ["can't be blank"]
    end

    test "with invalid token returns failure" do
      charge = %{charge_token_body().charge | token_uid: "invalid_token"}

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{provider: "paygent", charge: charge})
        |> json_response(400)
      assert response["error"] == "failure result 1"
    end

    test "charge payment with valid card_uuid returns success and charge uuid" do
      {message, client_service} = charge_uid_body()

      response =
        build_api_conn("private", client_service)
        |> post("/api/v1/payments/process", message)
        |> json_response(200)

      assert response["amount"] == 34567
      assert response["charge_uuid"] != nil
      assert response["currency"] == "JPY"
      assert response["result"] == "Payment successful"
    end

    test "charge payment with invalid data returns error and charge uuid" do
      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{})
        |> json_response(400)

      assert response["error"] == "bad request"
    end
  end

  def charge_token_body do
    %{
      provider: "paygent",
      charge: %{
        amount: 34567,
        currency: "JPY",
        reference: "optional",
        owner: %{
          object: "HubPayments.Wallet",
          uid: "wallet_uuuid"
        },
        token_uid: "valid_token",
        card: %{
          brand: "visa",
          exp_month: "05",
          exp_year: "23",
          last_four: "1881",
          fingerprint: "d94c89c3bb48759efceb824555580429"
        }
      }
    }
  end

  def charge_uid_body do
    user = HubIdentity.Factory.insert(:user)
    wallet = insert(:wallet, owner: %{object: "HubIdentity.User", uid: user.uid})
    credit_card = insert(:credit_card, vault_uuid: "valid_card_uuid", wallet: wallet)

    HubIdentity.Factory.insert(:confirmed_email, user: user)
    client_service = HubIdentity.Factory.insert(:client_service)
    reference = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

    loaded_user = HubIdentity.Identities.get_user(%{uid: user.uid})

    assert :ok == HubIdentity.Verifications.generate_code(loaded_user, client_service, reference)

    {:ok, [verification_code]} =
      HubIdentity.MementoRepo.get(HubIdentity.Verifications.VerificationCode, [
        {:==, :user_uid, user.uid}
      ])

    message = %{
      "provider" => "paygent",
      "charge" => %{
        "amount" => "34567",
        "currency" => "JPY",
        "reference" => "optional",
        "owner" => %{
          "object" => "HubPayments.Wallet",
          "uid" => wallet.uuid
        },
        "card_uuid" => credit_card.uuid,
        "authorization" => %{
          "code" => verification_code.code,
          "reference" => reference,
          "user_uuid" => user.uid
        }
      }
    }

    {message, client_service}
  end

  defp build_api_conn(type \\ "private", client_service \\ nil) do
    api_key =
      case client_service do
        nil ->
          HubIdentity.Factory.insert(:api_key, type: type)

        client_service ->
          HubIdentity.Factory.insert(:api_key, type: type, client_service: client_service)
      end

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
