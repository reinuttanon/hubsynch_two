defmodule HubLedger.Reports.TransactionsTest do
  use HubLedger.DataCase

  alias HubLedger.Reports.Transactions

  alias HubLedger.Ledgers.Entry

  import Ecto.Query, warn: false

  setup do
    setup_state()
  end

  describe "generate/1" do
    test "with account_id and from_date returns transactions", %{
      one_week_ago: one_week_ago,
      account: account
    } do
      transactions = Transactions.generate(%{account_id: account.id, from_date: one_week_ago})

      assert length(transactions) == 21

      for transaction <- transactions do
        assert DateTime.compare(transaction.reported_date, one_week_ago) == :gt
        assert transaction.account_id == account.id
      end
    end

    test "with account_uuid returns transactions", %{
      one_week_ago: one_week_ago,
      account: account
    } do
      transactions = Transactions.generate(%{account_uuid: account.uuid, from_date: one_week_ago})

      assert length(transactions) == 21

      for transaction <- transactions do
        assert transaction.account_id == account.id
      end
    end

    test "with invalid account_uuid returns error" do
      assert Transactions.generate(%{account_uuid: "555_bad"}) == {:error, "invalid account uuid"}
    end

    test "with account_id and to_date returns transactions", %{
      one_week_ago: one_week_ago,
      account: account
    } do
      transactions = Transactions.generate(%{account_id: account.id, to_date: one_week_ago})

      assert length(transactions) == 21

      for transaction <- transactions do
        assert DateTime.compare(transaction.reported_date, one_week_ago) == :lt
        assert transaction.account_id == account.id
      end
    end

    test "with account_id and description returns transactions", %{account: account} do
      transactions =
        Transactions.generate(%{account_id: account.id, description: "credit.index1"})

      assert length(transactions) == 2

      for transaction <- transactions do
        assert transaction.account_id == account.id
        assert transaction.description == "credit.index1"
      end
    end

    test "with entry and account filters returns transactions", %{account: account} do
      entry = Repo.one(from e in Entry, where: e.description == "entry_1.1")

      transactions = Transactions.generate(%{account_id: account.id, entry_id: entry.id})

      assert length(transactions) == 4

      for transaction <- transactions do
        assert transaction.account_id == account.id
        assert transaction.entry_id == entry.id
      end
    end

    test "with entry_uuid returns transactions", %{account: account} do
      entry = Repo.one(from e in Entry, where: e.description == "entry_1.1")

      transactions = Transactions.generate(%{account_uuid: account.uuid, entry_uuid: entry.uuid})

      assert length(transactions) == 4

      for transaction <- transactions do
        assert transaction.account_id == account.id
        assert transaction.entry_id == entry.id
      end
    end

    test "with invalid entry_uuid returns error" do
      assert Transactions.generate(%{entry_uuid: "555_bad"}) == {:error, "invalid entry uuid"}
    end

    test "with entry description returns transactions" do
      transactions = Transactions.generate(%{entry_description: "entry_1"})
      assert length(transactions) == 28
    end

    test "returns empty array if no transactions found" do
      assert Transactions.generate(%{entry_description: "not_here", order_by: "asc"}) == []
    end

    test "with description and from_date filters returns transactions", %{
      one_week_ago: one_week_ago
    } do
      transactions = Transactions.generate(%{description: "credit", from_date: one_week_ago})

      assert length(transactions) == 7

      for transaction <- transactions do
        assert DateTime.compare(transaction.reported_date, one_week_ago) == :gt
        assert transaction.description =~ "credit.index"
      end
    end

    test "with order_by asc returns transactions with newest first", %{
      one_week_ago: one_week_ago,
      account: account
    } do
      transactions =
        Transactions.generate(%{account_id: account.id, from_date: one_week_ago, order_by: "asc"})

      assert length(transactions) == 21

      first_transaction = List.first(transactions)
      last_transaction = List.last(transactions)

      assert DateTime.compare(first_transaction.reported_date, last_transaction.reported_date) ==
               :lt
    end

    test "with order_by desc returns transactions with oldest first", %{
      one_week_ago: one_week_ago,
      account: account
    } do
      transactions =
        Transactions.generate(%{account_id: account.id, from_date: one_week_ago, order_by: "desc"})

      assert length(transactions) == 21

      first_transaction = List.first(transactions)
      last_transaction = List.last(transactions)

      assert DateTime.compare(first_transaction.reported_date, last_transaction.reported_date) ==
               :gt
    end

    test "with string keys returns transactions", %{one_week_ago: one_week_ago} do
      transactions =
        Transactions.generate(%{"description" => "credit", "from_date" => one_week_ago})

      assert length(transactions) == 7
    end

    test "ignores invalid string keys and returns transactions", %{one_week_ago: one_week_ago} do
      transactions =
        Transactions.generate(%{
          "description" => "credit",
          "from_date" => one_week_ago,
          "shoe_size" => "30",
          "hair_color" => "bald"
        })

      assert length(transactions) == 7
    end
  end

  defp setup_state do
    account = insert(:account)
    other_account = insert(:account)
    one_week = 604_800
    one_day = 86_400

    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    one_week_ago = DateTime.add(now, -one_week)

    for index <- 1..7 do
      increment_one_day = DateTime.add(one_week_ago, index * one_day)
      decrement_one_day = DateTime.add(one_week_ago, -(index * one_day))

      entry_1 = insert(:entry, description: "entry_1.#{index}")
      entry_2 = insert(:entry, description: "entry_2.#{index}")

      insert(:transaction,
        account: account,
        entry: entry_1,
        reported_date: increment_one_day,
        description: "total.index#{index}"
      )

      insert(:transaction,
        account: account,
        entry: entry_1,
        reported_date: increment_one_day,
        kind: "credit",
        description: "credit.index#{index}"
      )

      insert(:transaction, account: other_account, reported_date: increment_one_day)

      insert(:transaction,
        account: account,
        entry: entry_1,
        reported_date: decrement_one_day,
        kind: "credit",
        description: "total.index#{index}"
      )

      insert(:transaction,
        account: account,
        entry: entry_1,
        reported_date: decrement_one_day,
        kind: "credit",
        description: "credit.index#{index}"
      )

      insert(:transaction,
        account: account,
        entry: entry_2,
        reported_date: increment_one_day,
        kind: "debit",
        description: "debit.index#{index}"
      )

      insert(:transaction,
        account: account,
        entry: entry_2,
        reported_date: decrement_one_day,
        kind: "debit",
        description: "debit.index#{index}"
      )

      insert(:transaction, account: other_account, reported_date: decrement_one_day)
    end

    %{
      account: account,
      one_week: one_week,
      one_day: one_day,
      one_week_ago: one_week_ago
    }
  end
end
