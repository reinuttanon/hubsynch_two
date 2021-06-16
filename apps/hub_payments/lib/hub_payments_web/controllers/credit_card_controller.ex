defmodule HubPaymentsWeb.CreditCardController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Wallets
  alias HubPayments.Wallets.CreditCard

  action_fallback HubPaymentsWeb.FallbackController

  def index(conn, _params) do
    credit_cards = Wallets.list_credit_cards()
    render(conn, "index.json", credit_cards: credit_cards)
  end

  def create(conn, %{"credit_card" => credit_card_params}) do
    with {:ok, %CreditCard{} = credit_card} <- Wallets.create_credit_card(credit_card_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.credit_card_path(conn, :show, credit_card))
      |> render("show.json", credit_card: credit_card)
    end
  end

  def show(conn, %{"id" => id}) do
    credit_card = Wallets.get_credit_card!(id)
    render(conn, "show.json", credit_card: credit_card)
  end

  def update(conn, %{"id" => id, "credit_card" => credit_card_params}) do
    credit_card = Wallets.get_credit_card!(id)

    with {:ok, %CreditCard{} = credit_card} <-
           Wallets.update_credit_card(credit_card, credit_card_params) do
      render(conn, "show.json", credit_card: credit_card)
    end
  end

  def delete(conn, %{"id" => id}) do
    credit_card = Wallets.get_credit_card!(id)

    with {:ok, %CreditCard{}} <- Wallets.delete_credit_card(credit_card) do
      send_resp(conn, :no_content, "")
    end
  end
end
