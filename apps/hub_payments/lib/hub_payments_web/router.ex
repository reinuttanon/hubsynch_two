defmodule HubPaymentsWeb.Router do
  use HubPaymentsWeb, :router

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug HubIdentityWeb.Authentication.ApiAuth, type: "private"
  end

  scope "/api/v1", HubPaymentsWeb.Api.V1 do
    pipe_through [:auth_api]

    post "/payments/process", PaymentController, :process

    post "/wallets", WalletController, :create

    post "/wallets/:uuid/credit_cards", CreditCardController, :create
  end
end
