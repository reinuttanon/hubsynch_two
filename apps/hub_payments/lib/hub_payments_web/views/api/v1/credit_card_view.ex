defmodule HubPaymentsWeb.Api.V1.CreditCardView do
  use HubPaymentsWeb, :view

  def render("show.json", %{credit_card: credit_card}) do
    %{
      "Object" => "CreditCard",
      "brand" => credit_card.brand,
      "exp_month" => credit_card.exp_month,
      "exp_year" => credit_card.exp_year,
      "last_four" => credit_card.last_four,
      "uuid" => credit_card.uuid
    }
  end
end