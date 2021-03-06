defmodule HubPaymentsWeb.Api.V1.CreditCardController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets
  alias HubPayments.Wallets.{CreditCard, Wallet}

  def index(conn, %{"wallet_uuid" => wallet_uuid}) do
    credit_cards = Wallets.list_credit_cards(%{wallet_uuid: wallet_uuid})
    render(conn, "index.json", credit_cards: credit_cards)
  end

  def show(conn, %{"wallet_uuid" => wallet_uuid, "credit_card_uuid" => credit_card_uuid}) do
    with %CreditCard{} = credit_card <-
           Wallets.get_credit_card(%{uuid: credit_card_uuid, wallet_uuid: wallet_uuid}) do
      render(conn, "show.json", %{credit_card: credit_card})
    else
      nil -> render(conn, "error.json", %{error: "no such credit card for this wallet"})
    end
  end

  def create(conn, %{"wallet_uuid" => wallet_uuid, "credit_card" => credit_card_params}) do
    with %Wallet{id: wallet_id} <- Wallets.get_wallet(%{uuid: wallet_uuid}),
         {:ok, credit_card} <- Wallets.create_credit_card(credit_card_params, wallet_id) do
      render(conn, "show.json", %{credit_card: credit_card})
    end
  end

  def update(conn, %{
        "wallet_uuid" => wallet_uuid,
        "credit_card_uuid" => credit_card_uuid,
        "credit_card_params" => credit_card_params
      }) do
    with %CreditCard{} = credit_card <-
           Wallets.get_credit_card(%{uuid: credit_card_uuid, wallet_uuid: wallet_uuid}),
         {:ok, credit_card} <- Wallets.update_credit_card(credit_card, credit_card_params) do
      render(conn, "show.json", %{credit_card: credit_card})
    else
      {:error, changeset} -> {:error, changeset}
      nil -> render(conn, "error.json", %{error: "no such credit card for this wallet"})
    end
  end

  def delete(conn, %{"wallet_uuid" => wallet_uuid, "credit_card_uuid" => credit_card_uuid}) do
    with %CreditCard{} = credit_card <-
           Wallets.get_credit_card(%{uuid: credit_card_uuid, wallet_uuid: wallet_uuid}),
         {:ok, _} <- Wallets.delete_credit_card(credit_card) do
      send_resp(conn, :no_content, "")
    else
      nil -> render(conn, "error.json", %{error: "no such credit card for this wallet"})
    end
  end
end
