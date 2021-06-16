defmodule HubPaymentsWeb.WalletView do
  use HubPaymentsWeb, :view
  alias HubPaymentsWeb.WalletView

  def render("index.json", %{wallets: wallets}) do
    %{data: render_many(wallets, WalletView, "wallet.json")}
  end

  def render("show.json", %{wallet: wallet}) do
    %{data: render_one(wallet, WalletView, "wallet.json")}
  end

  def render("wallet.json", %{wallet: wallet}) do
    %{
      id: wallet.id,
      owner: wallet.owner,
      prefered_credit_card_uuid: wallet.prefered_credit_card_uuid,
      uuid: wallet.uuid
    }
  end
end
