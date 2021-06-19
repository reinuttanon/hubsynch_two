defmodule HubPaymentsWeb.Api.V1.PaymentController do
  use HubPaymentsWeb, :controller

  alias HubIdentity.ClientServices.ClientService
  alias HubPayments.Providers.Vault
  alias HubPayments.{Wallets, Payments, Providers}

  def process(conn, %{"charge" => %{"token_uid" => token_uuid, "card" => card} = charge_params}) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         provider <- Providers.get_provider(%{name: "paygent"}),
         {:ok, credit_card} <- Wallets.create_credit_card(card),
         {:ok, charge} <- Payments.create_charge(charge_params, provider, credit_card),
         {:ok, messge} <-
           Providers.process_authorization(provider, charge, credit_card, token_uuid),
         {:ok, messge} <- Providers.process_capture(charge, provider, messge) do
      require IEx
      IEx.pry()
      conn
      # charge
    end
  end

  # find provider => default to paygent
  # send message to vault
  # save card data
  #  process response
  #  save vault uuid t/f
  #### send capture
  #### process captrue response
  #### return result

  def process(conn, %{"charge" => %{"card_uuid" => card_uuid, "auth" => auth} = charge}) do
    # with %ClientService{uid: cleint_service_uid} <- get_session(conn, :client_service) do
    # verify auth with hubidentity
    # find provider => default to paygent
    # send message to vault
    # process response
    #### send capture
    #### process captrue response
    #### return result
  end
end

# %{
#   charge: %{
#     amount: 34567,
#     currency: "JPY",
#     reference: "optional",
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
#     reference: "optional",
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
#       reference: "card-fingerprint"
#     }
# }
