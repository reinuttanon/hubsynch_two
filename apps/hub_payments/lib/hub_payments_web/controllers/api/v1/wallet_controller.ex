defmodule HubPaymentsWeb.Api.V1.WalletController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets
  alias HubPayments.Wallets.Wallet

  def create(conn, %{"wallet" => wallet_params}) do
    with {:ok, wallet} <- Wallets.create_wallet(wallet_params) do
      render(conn, "show.json", %{wallet: wallet})
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    with %Wallet{} = wallet <- Wallets.get_wallet(%{uuid: uuid}) do
      render(conn, "show.json", %{wallet: wallet})
    end
  end

  def update(conn, %{"uuid" => uuid, "wallet" => wallet_params}) do
    with %Wallet{} = wallet <- Wallets.get_wallet(%{uuid: uuid}),
    {:ok, updated_wallet} <- Wallets.update_wallet(wallet, wallet_params) do
      render(conn, "show.json", %{wallet: updated_wallet})
    end
  end
end
