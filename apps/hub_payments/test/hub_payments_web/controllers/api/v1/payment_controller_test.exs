defmodule HubPaymentsWeb.Api.V1.PaymentControllerTest do
  use HubPaymentsWeb.ConnCase

  alias HubPayments.{Wallets, Payments, Providers}

  describe "process/2" do
    test "charge payment with valid data returns success and charge uuid" do
      conn =
        build_api_conn()
        |> post("/api/v1/payments/process", charge_token_body())

      assert response(conn, 200) =~ "Payment successful"
    end

    test "charge payment with valid card_uuid returns success and charge uuid" do
      %{
        "charge" =>
          %{
            "card" => card,
            "card_uuid" => card_uuid,
            "authorization" => %{
              "user_uuid" => user_uuid,
              "code" => code,
              "reference" => reference
            }
          } = charge_params
      } = charge_uid_body()

      provider = Providers.get_provider(%{name: "paygent"})
      {:ok, credit_card} = Wallets.create_credit_card(card)
      {:ok, charge} = Payments.create_charge(charge_params, provider, credit_card)
      {:ok, message} = Providers.process_authorization(provider, charge, credit_card, card_uuid)
      {:ok, capture_message} = Providers.process_capture(charge, provider, message)

      assert capture_message.data.payment_id == "26505142"

      assert capture_message.response ==
               "\r\nresult=0\r\npayment_id=26505142\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=fvryIbkXNqjADaNqIRvpdcf5BDbhYQJhBsybDua0RGGVliC0QWHcXXTy6N7YeaUV\r\nmasked_card_number=************0000\r\ncard_valid_term=0122\r\nout_acs_html=",
             type: "capture"
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
      charge: %{
        amount: 34567,
        currency: "JPY",
        reference: "optional",
        owner: %{
          object: "HubPayments.Wallet",
          uid: "wallet_uuuid"
        },
        token_uid: "token_uuid",
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
    %{
      "charge" => %{
        "amount" => 34567,
        "currency" => "JPY",
        "reference" => "optional",
        "owner" => %{
          "object" => "HubPayments.Wallet",
          "uid" => "wallet_uuuid"
        },
        "card_uuid" => "vault_record_bcaf6604-5eb7-4110-b1ff-582935f488aa",
        "card" => %{
          "fingerprint" => "fingerprint",
          "last_four" => "1111",
          "exp_month" => "12",
          "exp_year" => "23",
          "brand" => "visa",
          "reference" => "card-fingerprint"
        },
        "authorization" => %{
          "code" => 4299,
          "reference" => "7o_Ntkc5tngK5rgKZ5bVPg",
          "user_uuid" => "c3143f00-ea06-4e7b-b233-3eb149c133de"
        }
      }
    }
  end

  defp build_api_conn(type \\ "private") do
    api_key = HubIdentity.Factory.insert(:api_key, type: type)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
