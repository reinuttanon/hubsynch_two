defmodule HubLedger.Accounts.BalanceServerTest do
  use HubLedger.DataCase, async: false

  alias HubLedger.Accounts
  alias HubLedger.Accounts.BalanceServer

  describe "verify_balances" do
    test "updates balances that satisfy the updated_at requirements" do
      asset_account = insert(:wallet_asset_account)
      liability_account = insert(:wallet_liability_account)
      too_new_account = insert(:account)
      too_old_account = insert(:account)

      now =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.truncate(:second)

      nine_seconds_ago = NaiveDateTime.add(now, -20, :second)

      three_min_ago = NaiveDateTime.add(now, -180, :second)

      asset_balance =
        insert(:balance, account: asset_account, updated_at: nine_seconds_ago, kind: "debit")

      liability_balance =
        insert(:balance, account: liability_account, updated_at: nine_seconds_ago, kind: "credit")

      too_new_balance =
        insert(:balance,
          account: too_new_account,
          kind: "credit",
          money: Money.new(1000, "JPY")
        )

      too_old_balance =
        insert(:balance,
          account: too_old_account,
          kind: "credit",
          money: Money.new(1000, "JPY"),
          updated_at: three_min_ago
        )

      for _ <- 1..3 do
        insert(:transaction, account: asset_account, kind: "debit")
        insert(:transaction, account: liability_account, kind: "credit")
        insert(:transaction, account: too_new_account, kind: "credit")
        insert(:transaction, account: too_old_account, kind: "credit")
      end

      assert Accounts.get_account_balance(%{uuid: asset_account.uuid}) == Money.new(30000, "JPY")

      assert Accounts.get_account_balance(%{uuid: liability_account.uuid}) ==
               Money.new(30000, "JPY")

      assert asset_balance.money == Money.new(0, "JPY")
      assert NaiveDateTime.compare(nine_seconds_ago, asset_balance.updated_at) == :eq
      assert liability_balance.money == Money.new(0, "JPY")
      assert NaiveDateTime.compare(nine_seconds_ago, liability_balance.updated_at) == :eq

      assert BalanceServer.verfy_balances() == {:ok, :ok}

      new_asset_balance = Accounts.get_balance!(asset_balance.id)
      new_liability_balance = Accounts.get_balance!(liability_balance.id)

      assert new_asset_balance.money == Money.new(30000, "JPY")
      assert new_liability_balance.money == Money.new(30000, "JPY")

      # These should not be updated because the balances are too old or too new. In reality the
      # transactions will never get inserted outside a journal entry, thus the balances will allways
      # get triggerd, also the BalanceServer gets started on app boot, thus this state of balances not
      # matching should never occur. 
      found_too_new_account = Accounts.get_balance!(too_new_balance.id)
      found_too_old_account = Accounts.get_balance!(too_old_balance.id)
      assert found_too_new_account.money == Money.new(1000, "JPY")
      assert found_too_old_account.money == Money.new(1000, "JPY")
    end
  end
end
