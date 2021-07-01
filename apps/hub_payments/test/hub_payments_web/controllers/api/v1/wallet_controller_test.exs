defmodule HubPaymentsWeb.Api.V1.WalletControllerTest do
  use HubPaymentsWeb.ConnCase

  alias HubPayments.Wallets
  alias HubPayments.Wallets.Wallet

  @create_attrs %{
    owner: %{},
    prefered_credit_card_uuid: "some prefered_credit_card_uuid",
    uuid: "some uuid"
  }
  @update_attrs %{
    prefered_credit_card_uuid: "some updated prefered_credit_card_uuid"
  }
  @invalid_attrs %{owner: nil, prefered_credit_card_uuid: nil, uuid: nil}

  setup %{conn: conn} do
    {:ok,
     conn:
       build_conn()
       |> put_req_header("accept", "application/json")
       |> put_req_header("x-api-key", HubIdentity.Factory.insert(:api_key, type: "private").data)}
  end

  describe "create wallet" do
    test "renders wallet when data is valid", %{conn: conn} do
      create_conn = post(conn, Routes.wallet_path(conn, :create), wallet: @create_attrs)

      assert %{
               "owner" => %{},
               "prefered_credit_card_uuid" => "some prefered_credit_card_uuid"
             } = json_response(create_conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      create_conn = post(conn, Routes.wallet_path(conn, :create), wallet: @invalid_attrs)

      assert json_response(create_conn, 400)["error"] == %{"owner" => ["can't be blank"]}
    end
  end

  describe "show wallet" do
    test "returns the wallet for given uuid", %{conn: conn} do
      wallet = insert(:wallet)

      for _ <- 1..3 do
        insert(:credit_card, %{wallet: wallet})
        insert(:credit_card)
      end

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}")
        |> json_response(200)

      assert response["Object"] == "Wallet"
      assert response["uuid"] == wallet.uuid
      assert length(response["credit_cards"]) == 3
    end
  end

  describe "update wallet" do
    test "renders wallet when data is valid", %{conn: conn} do
      wallet = insert(:wallet)

      for _ <- 1..3 do
        insert(:credit_card, %{wallet: wallet})
      end

      response =
        put(conn, "/api/v1/wallets/#{wallet.uuid}", wallet: @update_attrs)
        |> json_response(200)

      assert response["Object"] == "Wallet"
      assert response["uuid"] == wallet.uuid
      assert response["prefered_credit_card_uuid"] == "some updated prefered_credit_card_uuid"
      assert length(response["credit_cards"]) == 3
    end
  end
end
