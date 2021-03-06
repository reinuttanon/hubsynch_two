defmodule HubPaymentsWeb.Api.V1.PaymentControllerTest do
  use HubPaymentsWeb.ConnCase

  describe "process/2" do
    test "Paygent charge payment with valid data returns success and charge uuid" do
      response =
        build_api_conn()
        |> post("/api/v1/payments/process", paygent_charge_token_body())
        |> json_response(200)

      assert response["amount"] == 34567
      assert response["charge_uuid"] != nil
      assert response["currency"] == "JPY"
      assert response["result"] == "Payment successful"
    end

    test "SBPS charge payment with valid data returns success and charge uuid" do
      insert(:provider, name: "sbps")

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", sbps_charge_token_body())
        |> json_response(200)

      assert response["amount"] == 34567
      assert response["charge_uuid"] != nil
      assert response["currency"] == "JPY"
      assert response["result"] == "Payment successful"
    end

    test "Paygent charge with nil amount returns error" do
      charge = %{paygent_charge_token_body().charge | amount: nil}

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{provider: "paygent", charge: charge})
        |> json_response(400)

      assert response["error"]["money"] == ["can't be blank"]
    end

    test "Paygent charge with invalid token returns failure" do
      charge = %{paygent_charge_token_body().charge | token_uid: "invalid_token"}

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{provider: "paygent", charge: charge})
        |> json_response(400)

      assert response["error"] == "SomePaygentFailureMessage"
    end

    test "Paygent charge payment with valid card_uuid returns success and charge uuid" do
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

    test "Paygent charge payment with invalid data returns error and charge uuid" do
      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{})
        |> json_response(400)

      assert response["error"] == "bad request"
    end

    test "Paygent atm payment with valid data returns success response" do
      body = atm_payment_body()

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", body)
        |> json_response(200)

      assert response["amount"] == 3500
      assert response["atm_payment_uuid"] != nil
      assert response["currency"] == "JPY"
      assert response["result"] == "Payment successful"
      assert response["customer_number"] == "customer_number"
      assert response["pay_center_number"] == "pay_center_number"
      assert response["payment_limit_date"] == "some_date"
      assert response["result"] == "Payment successful"
    end

    test "Paygent atm payment without payment amount returns error" do
      body = %{atm_payment_body().atm_payment | amount: nil}

      response =
        build_api_conn()
        |> post("/api/v1/payments/process", %{atm_payment: body})
        |> json_response(400)

      assert response["error"] == %{"money" => ["can't be blank"]}
    end
  end

  def paygent_charge_token_body do
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

  def sbps_charge_token_body do
    %{
      provider: "sbps",
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
          cvv: "001",
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
      HubCluster.MementoRepo.get(HubIdentity.Verifications.VerificationCode, [
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

  def atm_payment_body do
    %{
      atm_payment: %{
        amount: 3500,
        currency: "JPY",
        owner: %{
          object: "HubPayments.Wallet",
          uid: "wallet_uuuid"
        },
        payment_detail: "???????????????",
        payment_detail_kana: "???????????????",
        payment_limit_date: 20
      }
    }
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
