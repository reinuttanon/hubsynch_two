defmodule HubPaymentsWeb.CreditCardView do
  use HubPaymentsWeb, :view
  alias HubPaymentsWeb.CreditCardView

  def render("index.json", %{credit_cards: credit_cards}) do
    %{data: render_many(credit_cards, CreditCardView, "credit_card.json")}
  end

  def render("show.json", %{credit_card: credit_card}) do
    %{data: render_one(credit_card, CreditCardView, "credit_card.json")}
  end

  def render("credit_card.json", %{credit_card: credit_card}) do
    %{
      id: credit_card.id,
      brand: credit_card.brand,
      exp_month: credit_card.exp_month,
      exp_year: credit_card.exp_year,
      fingerprint: credit_card.fingerprint,
      last_four: credit_card.last_four,
      uuid: credit_card.uuid
    }
  end
end
