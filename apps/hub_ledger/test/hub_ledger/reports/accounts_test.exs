defmodule HubLedger.Reports.AccountsTest do
  use HubLedger.DataCase

  alias HubLedger.Reports.Accounts

  setup do
    setup_state()
  end

  describe "generate/1" do
    test "with active returns all active or inactive accounts" do
      accounts = Accounts.generate(%{"active" => "true"})

      assert length(accounts) == 4

      for account <- accounts do
        assert account.active
      end

      accounts = Accounts.generate(%{active: false})

      assert length(accounts) == 4

      for account <- accounts do
        refute account.active
      end
    end

    test "with currency returns accounts" do
      accounts = Accounts.generate(%{"currency" => "JPY"})

      assert length(accounts) == 4

      for account <- accounts do
        assert account.currency == "JPY"
      end
    end

    test "with from_date returns accounts", %{one_week_ago: one_week_ago} do
      accounts = Accounts.generate(%{"from_date" => one_week_ago, "active" => "true"})

      assert length(accounts) == 2

      for account <- accounts do
        assert account.active
        assert NaiveDateTime.compare(account.inserted_at, one_week_ago) == :gt
      end
    end

    test "with kind returns accounts" do
      accounts = Accounts.generate(%{"kind" => "credit"})

      assert length(accounts) == 4

      for account <- accounts do
        assert account.kind == "credit"
      end
    end

    test "with name returns accounts" do
      accounts = Accounts.generate(%{"name" => "Fees"})

      assert length(accounts) == 4

      for account <- accounts do
        assert account.name =~ "Fees"
      end
    end

    test "with owner returns correct accounts" do
      accounts = Accounts.generate(%{owner: %{object: "Fabulous.User", uid: "hub_12345"}})
      assert length(accounts) == 4

      for account <- accounts do
        assert account.owner.object == "Fabulous.User"
        assert account.owner.uid == "hub_12345"
      end
    end

    test "with owner object returns correct accounts" do
      accounts = Accounts.generate(%{owner: %{object: "Fabulous.User"}})
      assert length(accounts) == 4

      for account <- accounts do
        assert account.owner.object == "Fabulous.User"
      end
    end

    test "with owner uid returns correct accounts" do
      accounts = Accounts.generate(%{owner: %{uid: "hub_12345"}})
      assert length(accounts) == 4

      for account <- accounts do
        assert account.owner.uid == "hub_12345"
      end
    end

    test "with to_date returns accounts", %{one_week_ago: one_week_ago} do
      accounts = Accounts.generate(%{"to_date" => one_week_ago, "active" => "true"})

      assert length(accounts) == 2

      for account <- accounts do
        assert account.active
        assert NaiveDateTime.compare(account.inserted_at, one_week_ago) == :lt
      end
    end

    test "with type returns accounts" do
      accounts = Accounts.generate(%{"type" => "revenue"})

      assert length(accounts) == 4

      for account <- accounts do
        assert account.type == "revenue"
      end
    end

    test "with uuids returns accounts matching those uuids" do
      uuids =
        Enum.map(1..3, fn _ -> insert(:account) end)
        |> Enum.map(& &1.uuid)

      accounts = Accounts.generate(%{"uuids" => uuids})

      assert length(accounts) == 3

      for account <- accounts do
        assert Enum.member?(uuids, account.uuid)
      end
    end
  end

  def setup_state do
    one_week = 604_800
    one_day = 86_400

    now =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.truncate(:second)

    one_week_ago = NaiveDateTime.add(now, -one_week)

    owner = %{object: "Fabulous.User", uid: "hub_12345"}

    for index <- 1..4 do
      active = rem(index, 2) == 0

      increment_one_day = NaiveDateTime.add(one_week_ago, index * one_day)
      decrement_one_day = NaiveDateTime.add(one_week_ago, -(index * one_day))

      insert(:account, %{
        active: active,
        currency: "JPY",
        owner: owner,
        type: "revenue",
        kind: "credit",
        name: "Fees.#{index}",
        inserted_at: increment_one_day
      })

      insert(:account, %{
        active: active,
        currency: "USD",
        type: "asset",
        kind: "debit",
        name: "Cash.#{index}",
        inserted_at: decrement_one_day
      })
    end

    %{
      one_day: one_day,
      one_week_ago: one_week_ago
    }
  end
end
