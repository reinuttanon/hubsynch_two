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
        currency: currency,
        payment_id: payment_id,
        pay_center_number: pay_center_number,
        customer_number: customer_number,
        conf_number: conf_number,
        payment_limit_date: payment_limit_date
      }) do
    %{
      result: "Payment successful",
      atm_payment_uuid: atm_payment_uuid,
      amount: amount,
      currency: currency,
      payment_id: payment_id,
      pay_center_number: pay_center_number,
      customer_number: customer_number,
      conf_number: conf_number,
      payment_limit_date: payment_limit_date
    }
  end
end
