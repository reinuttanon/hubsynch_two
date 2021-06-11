defmodule HubPaymentsWeb.ChargeControllerTest do
  use HubPaymentsWeb.ConnCase

  # alias HubPayments.Payments
  # alias HubPayments.Payments.Charge

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

  # def fixture(:charge) do
  #   {:ok, charge} = Payments.create_charge(@create_attrs)
  #   charge
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all charges", %{conn: conn} do
  #     conn = get(conn, Routes.charge_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create charge" do
  #   test "renders charge when data is valid", %{conn: conn} do
  #     conn = post(conn, Routes.charge_path(conn, :create), charge: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, Routes.charge_path(conn, :show, id))

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
  #     conn = post(conn, Routes.charge_path(conn, :create), charge: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update charge" do
  #   setup [:create_charge]

  #   test "renders charge when data is valid", %{conn: conn, charge: %Charge{id: id} = charge} do
  #     conn = put(conn, Routes.charge_path(conn, :update, charge), charge: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.charge_path(conn, :show, id))

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

  #   test "renders errors when data is invalid", %{conn: conn, charge: charge} do
  #     conn = put(conn, Routes.charge_path(conn, :update, charge), charge: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete charge" do
  #   setup [:create_charge]

  #   test "deletes chosen charge", %{conn: conn, charge: charge} do
  #     conn = delete(conn, Routes.charge_path(conn, :delete, charge))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.charge_path(conn, :show, charge))
  #     end
  #   end
  # end

  # defp create_charge(_) do
  #   charge = fixture(:charge)
  #   %{charge: charge}
  # end
end
