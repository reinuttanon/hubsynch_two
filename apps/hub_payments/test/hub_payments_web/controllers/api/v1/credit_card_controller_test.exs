defmodule HubPaymentsWeb.Api.V1.CreditCardControllerTest do
  use HubPaymentsWeb.ConnCase

  alias HubPayments.Wallets

  @create_attrs %{
    brand: "some brand",
    exp_month: "01",
    exp_year: "23",
    fingerprint: "some fingerprint",
    last_four: "4321",
    uuid: "some uuid"
  }
  @update_attrs %{
    exp_month: "12",
    exp_year: "32"
  }
  @invalid_attrs %{
    brand: nil,
    exp_month: nil,
    exp_year: nil,
    fingerprint: nil,
    last_four: nil,
    uuid: nil
  }

  setup %{conn: conn} do
    {:ok,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("x-api-key", HubIdentity.Factory.insert(:api_key, type: "private").data)}
  end

  describe "index" do
    test "lists all credit_cards", %{conn: conn} do
      credit_card = insert(:credit_card)
      insert(:credit_card)

      [response] =
        get(conn, "/api/v1/wallets/#{credit_card.wallet.uuid}/credit_cards")
        |> json_response(200)

      assert response["uuid"] == credit_card.uuid
    end

    test "returns [] if there are no credit cards", %{conn: conn} do
      wallet = insert(:wallet)

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards")
        |> json_response(200)

      assert response == []
    end
  end

  describe "show credit_card" do
    test "returns credit_card", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, %{wallet: wallet})

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid
        })
        |> json_response(200)

      assert response["Object"] == "CreditCard"
      assert response["uuid"] == credit_card.uuid
      assert response["last_four"] == credit_card.last_four
      assert response["exp_month"] == credit_card.exp_month
      assert response["exp_year"] == credit_card.exp_year
    end

    test "returns error if there is no credit_card in this wallet", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card)

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid
        })
        |> json_response(200)

      assert response == %{"error" => "no such credit card for this wallet"}
    end
  end

  describe "create credit_card" do
    test "renders credit_card when data is valid", %{conn: conn} do
      wallet = insert(:wallet)

      response =
        post(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card" => @create_attrs
        })
        |> json_response(200)

      assert response["Object"] == "CreditCard"
      assert response["last_four"] == @create_attrs.last_four
      assert response["exp_month"] == @create_attrs.exp_month
      assert response["exp_year"] == @create_attrs.exp_year
    end

    test "renders errors when data is invalid", %{conn: conn} do
      wallet = insert(:wallet)

      response =
        post(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards", %{
          "uuid" => wallet.uuid,
          "credit_card" => @invalid_attrs
        })
        |> json_response(400)

      assert response["error"] == %{
               "brand" => ["can't be blank"],
               "exp_month" => ["can't be blank"],
               "exp_year" => ["can't be blank"],
               "fingerprint" => ["can't be blank"],
               "last_four" => ["can't be blank"]
             }
    end
  end

  describe "update credit_card" do
    test "renders credit_card when data is valid", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, %{wallet: wallet})

      response =
        put(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid,
          "credit_card_params" => @update_attrs
        })
        |> json_response(200)

      assert response["Object"] == "CreditCard"
      assert response["uuid"] == credit_card.uuid
      assert response["last_four"] == credit_card.last_four
      assert response["exp_month"] == "12"
      assert response["exp_year"] == "32"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, %{wallet: wallet})

      response =
        put(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid,
          "credit_card_params" => @invalid_attrs
        })
        |> json_response(400)

      assert response["error"] == %{
               "exp_month" => ["can't be blank"],
               "exp_year" => ["can't be blank"]
             }
    end

    test "returns error if there is no such credit_card in this wallet", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card)

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid
        })
        |> json_response(200)

      assert response == %{"error" => "no such credit card for this wallet"}
    end
  end

  describe "delete credit_card" do
    test "deletes chosen credit_card", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, %{wallet: wallet})

      response =
        delete(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid
        })

      assert response.status == 204

      assert Wallets.get_credit_card(%{uuid: credit_card.uuid, wallet_uuid: wallet.uuid}) ==
               {:user_error, "Credit card not found"}
    end

    test "returns error if there is no such credit_card in this wallet", %{conn: conn} do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card)

      response =
        get(conn, "/api/v1/wallets/#{wallet.uuid}/credit_cards/#{credit_card.uuid}", %{
          "wallet_uuid" => wallet.uuid,
          "credit_card_uuid" => credit_card.uuid
        })
        |> json_response(200)

      assert response == %{"error" => "no such credit card for this wallet"}
    end
  end
end
