defmodule HubPaymentsWeb.WalletController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets
  alias HubPayments.Wallets.Wallet

  action_fallback HubPaymentsWeb.FallbackController

  def index(conn, _params) do
    wallets = Wallets.list_wallets()
    render(conn, "index.json", wallets: wallets)
  end

  def create(conn, %{"wallet" => wallet_params}) do
    with {:ok, %Wallet{} = wallet} <- Wallets.create_wallet(wallet_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.wallet_path(conn, :show, wallet))
      |> render("show.json", wallet: wallet)
    end
  end

  def show(conn, %{"id" => id}) do
    wallet = Wallets.get_wallet!(id)
    render(conn, "show.json", wallet: wallet)
  end

  def update(conn, %{"id" => id, "wallet" => wallet_params}) do
    wallet = Wallets.get_wallet!(id)

    with {:ok, %Wallet{} = wallet} <- Wallets.update_wallet(wallet, wallet_params) do
      render(conn, "show.json", wallet: wallet)
    end
  end

  def delete(conn, %{"id" => id}) do
    wallet = Wallets.get_wallet!(id)

    with {:ok, %Wallet{}} <- Wallets.delete_wallet(wallet) do
      send_resp(conn, :no_content, "")
    end
  end
end
