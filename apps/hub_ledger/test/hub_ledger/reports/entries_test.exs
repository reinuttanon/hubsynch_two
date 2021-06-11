defmodule HubLedger.Reports.EntriesTest do
  use HubLedger.DataCase

  alias HubLedger.Reports.Entries

  setup do
    setup_state()
  end

  describe "generate/1" do
    test "with description returns correct entries" do
      entries = Entries.generate(%{description: "entry_1"})
      assert length(entries) == 7

      for entry <- entries do
        assert entry.description =~ "entry_1"
      end
    end

    test "with from_date returns correct entries", %{one_week_ago: one_week_ago} do
      entries = Entries.generate(%{from_date: one_week_ago})
      assert length(entries) == 14

      for entry <- entries do
        assert NaiveDateTime.compare(entry.inserted_at, one_week_ago) == :gt
      end
    end

    test "with owner returns correct entries" do
      entries = Entries.generate(%{owner: %{object: "Fabulous.User", uid: "hub_12345"}})
      assert length(entries) == 7

      for entry <- entries do
        assert entry.owner.object == "Fabulous.User"
        assert entry.owner.uid == "hub_12345"
      end
    end

    test "with owner object returns correct entries" do
      entries = Entries.generate(%{owner: %{object: "Fabulous.User"}})
      assert length(entries) == 7

      for entry <- entries do
        assert entry.owner.object == "Fabulous.User"
      end
    end

    test "with owner uid returns correct entries" do
      entries = Entries.generate(%{owner: %{uid: "hub_12345"}})
      assert length(entries) == 7

      for entry <- entries do
        assert entry.owner.uid == "hub_12345"
      end
    end

    test "with to_date returns correct entries", %{one_week_ago: one_week_ago} do
      entries = Entries.generate(%{to_date: one_week_ago})
      assert length(entries) == 7

      for entry <- entries do
        assert NaiveDateTime.compare(entry.reported_date, one_week_ago) == :lt
      end
    end

    test "with uuids returns correct entries" do
      uuids =
        Enum.map(1..3, fn _ -> insert(:entry) end)
        |> Enum.map(& &1.uuid)

      entries = Entries.generate(%{uuids: uuids})

      assert length(entries) == 3

      for entry <- entries do
        assert Enum.member?(uuids, entry.uuid)
      end
    end

    test "preloads transaction account and entry", %{one_week_ago: one_week_ago} do
      transactions = Entries.generate(%{"from_date" => one_week_ago, "preload" => "true"})

      for transaction <- transactions do
        assert transaction.account.uuid != nil
        assert transaction.entry.uuid != nil
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

    for index <- 1..7 do
      increment_one_day = NaiveDateTime.add(one_week_ago, index * one_day)
      decrement_one_day = NaiveDateTime.add(one_week_ago, -(index * one_day))

      entry_1 =
        insert(:entry,
          description: "entry_1.#{index}",
          reported_date: increment_one_day,
          owner: owner
        )

      insert(:entry, description: "entry_2.#{index}", reported_date: increment_one_day)
      insert(:entry, description: "entry_3.#{index}", reported_date: decrement_one_day)

      insert(:transaction,
        entry: entry_1,
        reported_date: increment_one_day,
        description: "total.index#{index}"
      )

      insert(:transaction,
        entry: entry_1,
        reported_date: increment_one_day,
        description: "credit.index#{index}"
      )
    end

    %{
      one_week: one_week,
      one_week_ago: one_week_ago
    }
  end
end
