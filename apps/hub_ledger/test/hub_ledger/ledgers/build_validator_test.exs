defmodule HubLedger.Ledgers.BuildValidatorTest do
  use HubLedger.DataCase

  alias HubLedger.Ledgers.BuildValidator

  describe "validate_transactions_balance/1" do
    test "with credit and debit transactions returns {:ok transactions}" do
      debit_transactions =
        Enum.map(1..3, fn _ -> build_transaction(500, "debit", insert(:account)) end)

      credit_transactions =
        Enum.map(1..3, fn _ -> build_transaction(500, "credit", insert(:account)) end)

      assert {:ok, _transactions} =
               BuildValidator.validate_transactions_balance(
                 debit_transactions ++ credit_transactions
               )
    end

    test "with only credits returns error when credits and debits do not balance" do
      credit_transactions = [
        build_transaction(100, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "credit"}))
      ]

      assert {:error, "transactions do not balance"} ==
               BuildValidator.validate_transactions_balance(credit_transactions)
    end

    test "with only debits returns error when credits and debits do not balance" do
      debit_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "debit", insert(:account, %{kind: "debit"}))
      ]

      assert {:error, "transactions do not balance"} ==
               BuildValidator.validate_transactions_balance(debit_transactions)
    end

    test "returns error when credits and debits do not balance" do
      debit_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "debit", insert(:account, %{kind: "debit"}))
      ]

      credit_transactions = [
        build_transaction(100, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "credit"}))
      ]

      assert {:error, "transactions do not balance"} ==
               BuildValidator.validate_transactions_balance(
                 debit_transactions ++ credit_transactions
               )
    end

    test "with no transactions returns error" do
      assert {:error, "no transactions"} ==
               BuildValidator.validate_transactions_balance([])
    end
  end

  describe "validate_currencies_match/1" do
    test "when transaction currencies match account currencies returns {:ok transactions}" do
      debit_transactions =
        Enum.map(1..3, fn _ -> build_transaction(500, "debit", insert(:account)) end)

      credit_transactions =
        Enum.map(1..3, fn _ -> build_transaction(500, "credit", insert(:account)) end)

      assert {:ok, _transactions} =
               BuildValidator.validate_currencies_match(debit_transactions ++ credit_transactions)
    end

    test "returns error when transaction currency and currency does not match" do
      debit_transactions =
        Enum.map(1..3, fn _ ->
          build_transaction(500, "debit", insert(:account, %{currency: "USD"}))
        end)

      credit_transactions =
        Enum.map(1..3, fn _ ->
          build_transaction(500, "credit", insert(:account, %{currency: "USD"}))
        end)

      assert {:error, "account currencies and transaction currencies mismatch"} ==
               BuildValidator.validate_currencies_match(debit_transactions ++ credit_transactions)
    end

    test "returns error when different transactions have different currencies" do
      debit_transactions =
        Enum.map(1..2, fn _ ->
          build_transaction(500, "debit", insert(:account, %{currency: "JPY"}), "JPY")
        end)

      wrong_currency =
        build_transaction(500, "debit", insert(:account, %{currency: "USD"}), "USD")

      credit_transactions =
        Enum.map(1..3, fn _ ->
          build_transaction(500, "credit", insert(:account, %{currency: "JPY"}), "JPY")
        end)

      assert {:error, "account currencies and transaction currencies mismatch"} ==
               BuildValidator.validate_currencies_match(
                 [wrong_currency | debit_transactions] ++ credit_transactions
               )
    end
  end

  describe "validate_accounts_balance/1" do
    test "when account types and transactions balance returns {:ok transactions}" do
      debit_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "debit", insert(:account, %{kind: "debit"}))
      ]

      credit_transactions = [
        build_transaction(100, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "credit"})),
        build_transaction(200, "credit", insert(:account, %{kind: "credit"}))
      ]

      assert {:ok, _transactions} =
               BuildValidator.validate_accounts_balance(debit_transactions ++ credit_transactions)
    end

    test "returns error when accounts do not balance" do
      debit_transactions = [
        build_transaction(1000, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(100, "debit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "debit", insert(:account, %{kind: "debit"}))
      ]

      credit_transactions = [
        build_transaction(100, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(300, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "debit"})),
        build_transaction(400, "credit", insert(:account, %{kind: "credit"}))
      ]

      assert {:error, "accounts do not balance"} ==
               BuildValidator.validate_accounts_balance(debit_transactions ++ credit_transactions)
    end
  end

  defp build_transaction(amount, kind, account, currency \\ "JPY") do
    %{
      money: Money.new(amount, currency),
      description: "test.pay.#{kind}",
      kind: kind,
      account_id: account.id
    }
    |> HubLedger.Ledgers.Transaction.create_changeset()
  end
end
