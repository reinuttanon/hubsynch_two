defmodule HubPaymentsWeb.Api.V1.CreditCardController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets
  alias HubPayments.Wallets.Wallet

  def create(conn, %{"uuid" => uuid, "credit_card" => credit_card_params}) do
    with %Wallet{id: wallet_id} <- Wallets.get_wallet(%{uuid: uuid}),
         {:ok, credit_card} <- Wallets.create_credit_card(credit_card_params, wallet_id) do
      render(conn, "show.json", %{credit_card: credit_card})
    end
  end
end
