defmodule HubLedgerWeb.Api.V1.JournalEntryControllerTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  alias HubLedger.Ledgers

  describe "process/2" do
    test "returns success response with the total amount and creates a Journal Entry" do
      asset_account = insert(:wallet_asset_account)
      liability_account = insert(:wallet_liability_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)
        |> json_response(200)

      [debit_transaction, credit_transaction] = Ledgers.list_transactions()
      assert debit_transaction.money.amount == credit_transaction.money.amount
      assert debit_transaction.money.currency == credit_transaction.money.currency
      assert debit_transaction.account_id == asset_account.id
      assert credit_transaction.account_id == liability_account.id
      assert debit_transaction.entry == credit_transaction.entry

      assert response["status"] == "success"
      assert response["total_transactions"] == 2
    end

    test "returns success response with integer amount and creates a Journal Entry" do
      asset_account = insert(:wallet_asset_account)
      liability_account = insert(:wallet_liability_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: 1000
      }

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)
        |> json_response(200)

      [debit_transaction, credit_transaction] = Ledgers.list_transactions()
      assert debit_transaction.money.amount == credit_transaction.money.amount
      assert debit_transaction.money.currency == credit_transaction.money.currency
      assert debit_transaction.account_id == asset_account.id
      assert credit_transaction.account_id == liability_account.id
      assert debit_transaction.entry == credit_transaction.entry

      assert response["status"] == "success"
      assert response["total_transactions"] == 2
    end

    test "returns error message with no asset account" do
      insert(:wallet_liability_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      error =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)

      assert Ledgers.list_transactions() == []
      assert response(error, 400) =~ "transactions invalid"
    end

    test "returns error message with no liability account" do
      insert(:wallet_asset_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      error =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)

      assert Ledgers.list_transactions() == []
      assert response(error, 400) =~ "transactions invalid"
    end

    test "returns error message with invalid json config" do
      insert(:wallet_asset_account)
      insert(:wallet_liability_account)
      entry_builder = insert(:entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      error =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)

      assert Ledgers.list_transactions() == []
      assert response(error, 400) =~ "invalid json config"
    end

    test "returns error message with unexisting entry builder" do
      insert(:wallet_asset_account)
      insert(:wallet_liability_account)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      error =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/invalid_uuid", payload: payload)

      assert Ledgers.list_transactions() == []
      assert response(error, 400) =~ "invalid entry builder"
    end

    test "returns error message with invalid payload" do
      insert(:wallet_asset_account)
      insert(:wallet_liability_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        invalid_attr: "invalid",
        amount: "abc"
      }

      error =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}", payload: payload)

      assert Ledgers.list_transactions() == []
      assert response(error, 400) =~ "transactions invalid"
    end

    test "returns success response with the total amount and creates a Journal Entry with safe param" do
      asset_account = insert(:wallet_asset_account)
      liability_account = insert(:wallet_liability_account)
      entry_builder = insert(:wallet_entry_builder)

      payload = %{
        sender: "liability_uid",
        amount: "1000"
      }

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry/process/#{entry_builder.uuid}",
          payload: payload,
          safe: true
        )
        |> json_response(200)

      [debit_transaction, credit_transaction] = Ledgers.list_transactions()
      assert debit_transaction.money.amount == credit_transaction.money.amount
      assert debit_transaction.money.currency == credit_transaction.money.currency
      assert debit_transaction.account_id == asset_account.id
      assert credit_transaction.account_id == liability_account.id
      assert debit_transaction.entry == credit_transaction.entry

      assert response["status"] == "success"
      assert response["total_transactions"] == 2
    end
  end

  describe "create/2" do
    test "returns success response with the total amount and creates a Journal Entry" do
      build_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(700, "credit", insert(:account, %{kind: "credit"}))
      ]

      build_entry = %{description: "New Laptop"}

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry",
          payload: %{entry: build_entry, transactions: build_transactions}
        )
        |> json_response(200)

      [entry] = Ledgers.list_entries()
      transactions = Ledgers.list_transactions()
      assert response["total_transactions"] == length(transactions)
      assert entry.description == "New Laptop"
    end

    test "returns error message with no transactions" do
      build_entry = %{description: "New Laptop"}

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry", payload: %{entry: build_entry, transactions: []})
        |> json_response(200)

      assert Ledgers.list_transactions() == []
      assert response["total_transactions"] == 0
    end

    test "returns error message with one invalid transactions" do
      build_entry = %{description: "New Laptop"}

      transactions = [
        %{
          money: %{amount: 1000, currency: "JPY"},
          description: "test.pay.debit",
          kind: "debit",
          account_uuid: "invalid"
        }
      ]

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry",
          payload: %{entry: build_entry, transactions: transactions}
        )

      assert Ledgers.list_transactions() == []
      assert response(response, 400) =~ "can't be blank"
    end

    test "returns error message with 2 invalid transactions and 1 valid transactions" do
      build_entry = %{description: "New Laptop"}

      build_transactions = build_transaction(100, "debit", insert(:account, %{kind: "debit"}))

      invalid_transactions = [
        %{
          money: %{amount: 1000, currency: "JPY"},
          description: "test.pay.debit",
          kind: "debit",
          account_uuid: "invalid1"
        },
        %{
          money: %{amount: 2000, currency: "JPY"},
          description: "test.pay.debit",
          kind: "debit",
          account_uuid: "invalid2"
        }
      ]

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry",
          payload: %{
            entry: build_entry,
            transactions: [build_transactions | invalid_transactions]
          }
        )

      assert length(response.assigns.error.transactions) == 2
      assert Ledgers.list_transactions() == []
      assert response(response, 400) =~ "can't be blank"
    end

    test "returns error message with invalid entry" do
      build_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(700, "credit", insert(:account, %{kind: "credit"}))
      ]

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry", payload: %{entry: %{}, transactions: build_transactions})

      assert Ledgers.list_transactions() == []
      assert length(response.assigns.error.transactions) == 0
      assert response.assigns.error.entry.description == ["can't be blank"]
      assert response(response, 400) =~ "can't be blank"
    end

    test "returns error message with invalid entry, 1 invalid transaction and 2 valid transactions" do
      build_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "credit", insert(:account, %{kind: "credit"}))
      ]

      invalid_transaction = %{
        money: %{amount: 1000, currency: "JPY"},
        description: "test.pay.debit",
        kind: "debit",
        account_uuid: "invalid1"
      }

      response =
        build_api_conn()
        |> post("/api/v1/journal_entry",
          payload: %{entry: %{}, transactions: [invalid_transaction | build_transactions]}
        )

      assert Ledgers.list_transactions() == []
      assert length(response.assigns.error.transactions) == 1
      assert response.assigns.error.entry.description == ["can't be blank"]
      assert response(response, 400) =~ "can't be blank"
    end
  end

  defp build_api_conn do
    api_key = HubIdentity.Factory.insert(:api_key, type: "private")

    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("x-api-key", api_key.data)
  end

  defp build_transaction(amount, kind, account) do
    %{
      money: Money.new(amount, "JPY"),
      description: "test.pay.#{kind}",
      kind: kind,
      account_uuid: account.uuid
    }
  end
end
