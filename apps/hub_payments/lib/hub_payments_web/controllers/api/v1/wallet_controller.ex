defmodule HubPaymentsWeb.Api.V1.WalletController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets

  def create(conn, %{"wallet" => wallet_params}) do
    with {:ok, wallet} <- Wallets.create_wallet(wallet_params) do
      render(conn, "show.json", %{wallet: wallet})
    end
  end
end
