defmodule HubPaymentsWeb.PointController do
  use HubPaymentsWeb, :controller

  alias HubPayments.Payments
  alias HubPayments.Payments.Point

  def index(conn, _params) do
    points = Payments.list_points()
    render(conn, "index.json", points: points)
  end

  def create(conn, %{"point" => point_params}) do
    with {:ok, %Point{} = point} <- Payments.create_point(point_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.point_path(conn, :show, point))
      |> render("show.json", point: point)
    end
  end

  def show(conn, %{"id" => id}) do
    point = Payments.get_point!(id)
    render(conn, "show.json", point: point)
  end

  def update(conn, %{"id" => id, "point" => point_params}) do
    point = Payments.get_point!(id)

    with {:ok, %Point{} = point} <- Payments.update_point(point, point_params) do
      render(conn, "show.json", point: point)
    end
  end

  def delete(conn, %{"id" => id}) do
    point = Payments.get_point!(id)

    with {:ok, %Point{}} <- Payments.delete_point(point) do
      send_resp(conn, :no_content, "")
    end
  end
end
