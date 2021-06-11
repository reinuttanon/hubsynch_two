defmodule HubLedger.Accounts.BalanceTest do
  use HubLedger.DataCase

  alias HubLedger.Accounts.Balance

  describe "create_changeset/1" do
    test "with an account reutrns valid changeset" do
      account = insert(:account)

      changeset = Balance.create_changeset(account)
      assert changeset.valid?
      assert changeset.changes[:account_id] == account.id
      assert changeset.changes[:money] == Money.new(0, account.currency)
      refute changeset.changes[:uuid] == nil
    end
  end

  describe "update_changeset/2" do
    test "with valid money object updates new balance" do
      balance = insert(:balance)
      assert Money.zero?(balance.money)

      new_money = Money.new(10_000, "JPY")
      changeset = Balance.update_changeset(balance, new_money)

      assert changeset.valid?
      assert Money.equals?(changeset.changes[:money], new_money)
    end
  end
end
