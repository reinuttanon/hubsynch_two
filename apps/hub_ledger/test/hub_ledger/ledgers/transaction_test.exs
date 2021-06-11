defmodule HubLedger.Ledgers.TransactionTest do
  use HubLedger.DataCase

  alias HubLedger.Ledgers.Transaction

  describe "create_changeset/1" do
    test "with valid attrs returns valid changeset" do
      account = insert(:account)
      reported_date = "2016-05-24T13:26:08Z"

      attrs = %{
        money: %{amount: 1000, currency: "JPY"},
        description: "Some description",
        kind: "debit",
        reported_date: reported_date,
        account_id: account.id
      }

      changeset = Transaction.create_changeset(attrs)
      assert changeset.valid?
      assert changeset.changes.reported_date == ~U[2016-05-24 13:26:08Z]
    end

    test "with valid attrs and nil reported date returns valid changeset with current date" do
      account = insert(:account)

      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      attrs = %{
        money: %{amount: 1000, currency: "JPY"},
        description: "Some description",
        kind: "debit",
        account_id: account.id
      }

      changeset = Transaction.create_changeset(attrs)
      assert changeset.valid?

      assert DateTime.compare(changeset.changes.reported_date, now) == :eq
    end
  end
end
