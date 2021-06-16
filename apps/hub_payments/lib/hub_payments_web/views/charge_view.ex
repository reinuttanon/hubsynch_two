defmodule HubPaymentsWeb.ChargeView do
  use HubPaymentsWeb, :view
  alias HubPaymentsWeb.ChargeView

  def render("index.json", %{charges: charges}) do
    %{data: render_many(charges, ChargeView, "charge.json")}
  end

  def render("show.json", %{charge: charge}) do
    %{data: render_one(charge, ChargeView, "charge.json")}
  end

  def render("charge.json", %{charge: charge}) do
    %{
      id: charge.id,
      reference: charge.reference,
      request_date: charge.request_date,
      process_date: charge.process_date,
      settle_date: charge.settle_date,
      money: charge.money,
      uuid: charge.uuid,
      owner: charge.owner
    }
  end
end
