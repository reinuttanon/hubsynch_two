defmodule HubPaymentsWeb.Api.V1.PaymentView do
  use HubPaymentsWeb, :view

  def render("success.json", %{charge_uuid: charge_uuid}) do
    %{
      result: "Payment successful",
      charge_uuid: charge_uuid
    }
  end
end
