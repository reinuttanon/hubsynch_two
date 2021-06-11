defmodule HubLedgerWeb.Api.V1.AccountControllerTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  alias HubLedger.Accounts

  describe "create/2" do
    test "returns success response and creates an Account with valid values" do
      account_params = %{currency: "JPY", name: "ErinTest", type: "equity"}

      build_api_conn()
      |> post("/api/v1/accounts", account: account_params)
      |> json_response(200)

      [account] = Accounts.list_accounts()

      assert account.currency == account_params.currency
      assert account.name == account_params.name
      assert account.type == account_params.type
    end

    test "returns error with invalid values" do
      account_params = %{}

      response =
        build_api_conn()
        |> post("/api/v1/accounts", account: account_params)
        |> json_response(400)

      assert Accounts.list_accounts() == []
      assert response["error"]["currency"] == ["can't be blank"]
      assert response["error"]["name"] == ["can't be blank"]
      assert response["error"]["type"] == ["can't be blank"]
    end
  end

  describe "balance/2" do
    test "returns the balance with valid account uuid" do
      account = insert(:account, %{kind: "credit", currency: "JPY"})

      for _ <- 1..3 do
        insert(:transaction, %{
          account: account,
          kind: "credit",
          money: Money.new(500, "JPY")
        })

        insert(:transaction, %{
          account: account,
          kind: "debit",
          money: Money.new(200, "JPY")
        })
      end

      response =
        build_api_conn()
        |> get("/api/v1/accounts/#{account.uuid}/balance")
        |> json_response(200)

      assert response["money"] == %{"amount" => 900, "currency" => "JPY"}
      assert response["Object"] == "Account.Balance"
      assert response["uuid"] == account.uuid
    end

    test "returns error with invalid account uuid" do
      response =
        build_api_conn()
        |> get("/api/v1/accounts/invalid_uuid/balance")
        |> json_response(400)

      assert response["error"] == "invalid Account"
    end
  end

  describe "running_balance/2" do
    test "returns the balance with valid account uuid" do
      balance = insert(:balance, money: Money.new(777, "JPY"))

      response =
        build_api_conn()
        |> get("/api/v1/accounts/#{balance.account.uuid}/running_balance")
        |> json_response(200)

      assert response["money"] == %{"amount" => 777, "currency" => "JPY"}
      assert response["Object"] == "Balance"
      assert response["uuid"] == balance.account.uuid
    end

    test "returns error with invalid account uuid" do
      response =
        build_api_conn()
        |> get("/api/v1/accounts/invalid_uuid/running_balance")
        |> json_response(400)

      assert response["error"] == "Account not found"
    end
  end

  defp build_api_conn do
    api_key = HubLedger.HubIdentityFactory.insert(:api_key)

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end
end
