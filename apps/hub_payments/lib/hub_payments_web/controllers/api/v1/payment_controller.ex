defmodule HubPaymentsWeb.Api.V1.PaymentController do
  use HubPaymentsWeb, :controller

  alias HubIdentity.ClientServices.ClientService
  alias HubPayments.Payments.Charge
  alias HubPayments.{Wallets, Payments, Providers}
  alias HubPayments.Wallets.CreditCard
  alias HubPayments.Providers.Provider

  def process(conn, %{
        "provider" => "paygent",
        "charge" => %{"token_uid" => token_uuid, "card" => card} = charge_params
      }) do
    with %Provider{} = provider <- Providers.get_provider(%{name: "paygent"}),
         {:ok, credit_card} <- Wallets.create_credit_card(card),
         {:ok, %Charge{money: %Money{amount: amount, currency: currency}} = charge} <-
           Payments.create_charge(charge_params, provider, credit_card),
         {:ok, _message} <-
           Providers.process_charge(provider, charge, credit_card, token_uuid) do
      render(conn, "success.json", %{
        charge_uuid: charge.uuid,
        amount: amount,
        currency: currency,
        card_uuid: credit_card.uuid
      })
    end
  end

  def process(conn, %{
        "provider" => "paygent",
        "charge" =>
          %{
            "card_uuid" => card_uuid,
            "authorization" => %{
              "user_uuid" => user_uuid,
              "code" => code,
              "reference" => reference
            }
          } = charge_params
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         {:ok, _} <-
           HubIdentity.Verifications.validate_code(code, user_uuid, client_service, reference),
         %Provider{} = provider <- Providers.get_provider(%{name: "paygent"}),
         %CreditCard{} = credit_card <-
           Wallets.get_credit_card(%{
             uuid: card_uuid,
             owner: %{object: "HubIdentity.User", uid: user_uuid}
           }),
         {:ok, %Charge{money: %Money{amount: amount, currency: currency}} = charge} <-
           Payments.create_charge(charge_params, provider, credit_card),
         {:ok, _message} <-
           Providers.process_charge(provider, charge, credit_card) do
      render(conn, "success.json", %{
        charge_uuid: charge.uuid,
        amount: amount,
        currency: currency,
        card_uuid: card_uuid
      })
    end
  end

  def process(conn, %{
        "provider" => "sbps",
        "charge" => %{"token_uid" => token_uuid, "card" => card} = charge_params
      }) do
    with %Provider{} = provider <- Providers.get_provider(%{name: "sbps"}),
         {:ok, credit_card} <- Wallets.create_credit_card(card),
         {:ok, %Charge{money: %Money{amount: amount, currency: currency}} = charge} <-
           Payments.create_charge(charge_params, provider, credit_card),
         {:ok, _message} <-
           Providers.process_charge(provider, charge, credit_card, token_uuid) do
      render(conn, "success.json", %{
        charge_uuid: charge.uuid,
        amount: amount,
        currency: currency,
        card_uuid: credit_card.uuid
      })
    end
  end

  def process(conn, %{
        "provider" => "sbps",
        "charge" =>
          %{
            "card_uuid" => card_uuid,
            "authorization" => %{
              "user_uuid" => user_uuid,
              "code" => code,
              "reference" => reference
            }
          } = charge_params
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         {:ok, _} <-
           HubIdentity.Verifications.validate_code(code, user_uuid, client_service, reference),
         %Provider{} = provider <- Providers.get_provider(%{name: "sbps"}),
         %CreditCard{} = credit_card <-
           Wallets.get_credit_card(%{
             uuid: card_uuid,
             owner: %{object: "HubIdentity.User", uid: user_uuid}
           }),
         {:ok, %Charge{money: %Money{amount: amount, currency: currency}} = charge} <-
           Payments.create_charge(charge_params, provider, credit_card),
         {:ok, _message} <-
           Providers.process_charge(provider, charge, credit_card) do
      render(conn, "success.json", %{
        charge_uuid: charge.uuid,
        amount: amount,
        currency: currency,
        card_uuid: card_uuid
      })
    end
  end

  def process(_conn, _), do: {:error, "bad request"}
end

# %{
#   charge: %{
#     amount: 34567,
#     currency: "JPY",
#     owner: %{
#       object: "HubPayments.Wallet",
#       uid: "wallet_uuuid"
#     }
#     card_uuid: "card_uuuid",
#     authorization: %{
#       code: 1234,
#       reference: "reference from client service",
#       user_uuid: "hub_user_uuid"
#     }
# }

# %{
#   charge: %{
#     amount: 34567,
#     currency: "JPY",
#     reference: "reference",
#     owner: %{
#       object: "HubPayments.Wallet",
#       uid: "wallet_uuuid"
#     }
#     token_uuid: "token_uuuid",
#     card: %{
#       last_four: 1234,
#       exp_month: "12",
#       exp_year: "2023",
#       brand: "visa",
#       fingerprint: "card-fingerprint"
#     }
# }
