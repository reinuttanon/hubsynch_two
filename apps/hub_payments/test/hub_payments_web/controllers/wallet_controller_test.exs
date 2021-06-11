defmodule HubPaymentsWeb.WalletControllerTest do
  use HubPaymentsWeb.ConnCase

  # alias HubPayments.Wallets
  # alias HubPayments.Wallets.Wallet

  # @create_attrs %{
  #   owner: %{},
  #   prefered_credit_card_uuid: "some prefered_credit_card_uuid",
  #   uuid: "some uuid"
  # }
  # @update_attrs %{
  #   owner: %{},
  #   prefered_credit_card_uuid: "some updated prefered_credit_card_uuid",
  #   uuid: "some updated uuid"
  # }
  # @invalid_attrs %{owner: nil, prefered_credit_card_uuid: nil, uuid: nil}

  # def fixture(:wallet) do
  #   {:ok, wallet} = Wallets.create_wallet(@create_attrs)
  #   wallet
  # end

  # setup %{conn: conn} do
  #   {:ok, conn: put_req_header(conn, "accept", "application/json")}
  # end

  # describe "index" do
  #   test "lists all wallets", %{conn: conn} do
  #     conn = get(conn, Routes.wallet_path(conn, :index))
  #     assert json_response(conn, 200)["data"] == []
  #   end
  # end

  # describe "create wallet" do
  #   test "renders wallet when data is valid", %{conn: conn} do
  #     conn = post(conn, Routes.wallet_path(conn, :create), wallet: @create_attrs)
  #     assert %{"id" => id} = json_response(conn, 201)["data"]

  #     conn = get(conn, Routes.wallet_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "owner" => %{},
  #              "prefered_credit_card_uuid" => "some prefered_credit_card_uuid",
  #              "uuid" => "some uuid"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, Routes.wallet_path(conn, :create), wallet: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "update wallet" do
  #   setup [:create_wallet]

  #   test "renders wallet when data is valid", %{conn: conn, wallet: %Wallet{id: id} = wallet} do
  #     conn = put(conn, Routes.wallet_path(conn, :update, wallet), wallet: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.wallet_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "owner" => %{},
  #              "prefered_credit_card_uuid" => "some updated prefered_credit_card_uuid",
  #              "uuid" => "some updated uuid"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, wallet: wallet} do
  #     conn = put(conn, Routes.wallet_path(conn, :update, wallet), wallet: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete wallet" do
  #   setup [:create_wallet]

  #   test "deletes chosen wallet", %{conn: conn, wallet: wallet} do
  #     conn = delete(conn, Routes.wallet_path(conn, :delete, wallet))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.wallet_path(conn, :show, wallet))
  #     end
  #   end
  # end

  # defp create_wallet(_) do
  #   wallet = fixture(:wallet)
  #   %{wallet: wallet}
  # end
end
