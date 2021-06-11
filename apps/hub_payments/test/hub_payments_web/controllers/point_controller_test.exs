defmodule HubPaymentsWeb.PointControllerTest do
  use HubPaymentsWeb.ConnCase

  # alias HubPayments.Payments
  # alias HubPayments.Payments.Point

  # @create_attrs %{
  #   money: %{},
  #   owner: %{},
  #   process_date: "2010-04-17T14:00:00Z",
  #   reference: "some reference",
  #   request_date: "2010-04-17T14:00:00Z",
  #   settle_date: "2010-04-17T14:00:00Z",
  #   uuid: "some uuid"
  # }
  # @update_attrs %{
  #   money: %{},
  #   owner: %{},
  #   process_date: "2011-05-18T15:01:01Z",
  #   reference: "some updated reference",
  #   request_date: "2011-05-18T15:01:01Z",
  #   settle_date: "2011-05-18T15:01:01Z",
  #   uuid: "some updated uuid"
  # }
  # @invalid_attrs %{money: nil, owner: nil, process_date: nil, reference: nil, request_date: nil, settle_date: nil, uuid: nil}

  # def fixture(:point) do
  #   {:ok, point} = Payments.create_point(@create_attrs)
  #   point
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all points", %{conn: conn} do
  #     conn = get(conn, Routes.point_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create point" do
  #   test "renders point when data is valid", %{conn: conn} do
  #     conn = post(conn, Routes.point_path(conn, :create), point: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, Routes.point_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "money" => %{},
  #              "owner" => %{},
  #              "process_date" => "2010-04-17T14:00:00Z",
  #              "reference" => "some reference",
  #              "request_date" => "2010-04-17T14:00:00Z",
  #              "settle_date" => "2010-04-17T14:00:00Z",
  #              "uuid" => "some uuid"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, Routes.point_path(conn, :create), point: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update point" do
  #   setup [:create_point]

  #   test "renders point when data is valid", %{conn: conn, point: %Point{id: id} = point} do
  #     conn = put(conn, Routes.point_path(conn, :update, point), point: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.point_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "money" => %{},
  #              "owner" => %{},
  #              "process_date" => "2011-05-18T15:01:01Z",
  #              "reference" => "some updated reference",
  #              "request_date" => "2011-05-18T15:01:01Z",
  #              "settle_date" => "2011-05-18T15:01:01Z",
  #              "uuid" => "some updated uuid"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, point: point} do
  #     conn = put(conn, Routes.point_path(conn, :update, point), point: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete point" do
  #   setup [:create_point]

  #   test "deletes chosen point", %{conn: conn, point: point} do
  #     conn = delete(conn, Routes.point_path(conn, :delete, point))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.point_path(conn, :show, point))
  #     end
  #   end
  # end

  # defp create_point(_) do
  #   point = fixture(:point)
  #   %{point: point}
  # end
end
