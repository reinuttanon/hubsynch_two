defmodule HubPaymentsWeb.Api.V1.PaymentView do
  use HubPaymentsWeb, :view

  def render("success.json", %{
        charge_uuid: charge_uuid,
        amount: amount,
        currency: currency,
        card_uuid: card_uuid
      }) do
    %{
      result: "Payment successful",
      charge_uuid: charge_uuid,
      amount: amount,
      currency: currency,
      card_uuid: card_uuid
    }
  end

  def render("success.json", %{
        atm_payment_uuid: atm_payment_uuid,
        amount: amount,
        currency: currency
      }) do
    %{
      result: "Payment successful",
      atm_payment_uuid: atm_payment_uuid,
      amount: amount,
      currency: currency
    }
  end
end
