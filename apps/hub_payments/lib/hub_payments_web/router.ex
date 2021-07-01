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
    get "/wallets/:uuid", WalletController, :show
    put "/wallets/:uuid", WalletController, :update

    get "/wallets/:wallet_uuid/credit_cards", CreditCardController, :index
    post "/wallets/:wallet_uuid/credit_cards", CreditCardController, :create
    get "/wallets/:wallet_uuid/credit_cards/:uuid", CreditCardController, :show
    put "/wallets/:wallet_uuid/credit_cards/:uuid", CreditCardController, :update
    delete "/wallets/:wallet_uuid/credit_cards/:uuid", CreditCardController, :delete
  end
end
