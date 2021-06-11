defmodule HubPaymentsWeb.PointView do
  use HubPaymentsWeb, :view
  alias HubPaymentsWeb.PointView

  def render("index.json", %{points: points}) do
    %{data: render_many(points, PointView, "point.json")}
  end

  def render("show.json", %{point: point}) do
    %{data: render_one(point, PointView, "point.json")}
  end

  def render("point.json", %{point: point}) do
    %{id: point.id,
      reference: point.reference,
      request_date: point.request_date,
      process_date: point.process_date,
      settle_date: point.settle_date,
      money: point.money,
      uuid: point.uuid,
      owner: point.owner}
  end
end
