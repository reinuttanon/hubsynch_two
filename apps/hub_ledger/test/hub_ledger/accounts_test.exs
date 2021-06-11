defmodule HubLedger.AccountsTest do
  use HubLedger.DataCase

  alias HubLedger.Accounts
  alias HubLedger.Accounts.{Account, Balance}
  alias HubLedger.Embeds.Owner

  describe "accounts" do
    test "list_accounts/0 returns all accounts" do
      account = insert(:account)
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = insert(:account)
      found_account = Accounts.get_account!(account.id)
      assert found_account.uuid == account.uuid
    end

    test "get_account/1 returns the account with given uuid" do
      account = insert(:account)
      assert Accounts.get_account(%{uuid: account.uuid}) == account
    end

    test "get_account/1 returns nil with invalid uuid" do
      assert Accounts.get_account(%{uuid: "invalid"}) == nil
    end

    test "get_account_by_owner/1 returns the account of an specific owner" do
      owner = %Owner{object: "some_owner", uid: "some_uid"}
      insert(:account, owner: owner)

      assert founded_account =
               Accounts.get_account_by_owner(%{"object" => owner.object, "uid" => owner.uid})

      assert founded_account.owner != nil
      assert founded_account.owner.object == "some_owner"
      assert founded_account.owner.uid == "some_uid"
    end

    test "get_account_by_owner/1 returns nil" do
      assert Accounts.get_account_by_owner(%{
               "object" => "doesn't exist",
               "uid" => "doesn't exist"
             }) == nil
    end

    test "get_account_balance/1 with credit account returns balance" do
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

      assert Accounts.get_account_balance(%{uuid: account.uuid}) == Money.new(900, "JPY")
    end

    test "get_account_balance/1 with debit account returns balance" do
      account = insert(:account, %{kind: "debit", currency: "JPY"})

      for _ <- 1..3 do
        insert(:transaction, %{
          account: account,
          kind: "debit",
          money: Money.new(500, "JPY")
        })

        insert(:transaction, %{
          account: account,
          kind: "credit",
          money: Money.new(200, "JPY")
        })
      end

      assert Accounts.get_account_balance(%{uuid: account.uuid}) == Money.new(900, "JPY")
    end

    test "get_account_balance/1 with no transactions returns 0" do
      account = insert(:account)
      assert Accounts.get_account_balance(%{uuid: account.uuid}) == Money.new(0, "JPY")
    end

    test "create_account/1 with valid data creates an account and a balance" do
      attrs = %{currency: "JPY", name: "ErinTest", type: "equity"}
      assert {:ok, %{account: account, balance: balance}} = Accounts.create_account(attrs)
      assert account.active == true
      assert account.currency == "JPY"
      assert account.kind == "credit"
      assert account.meta_data == %{}
      assert account.name == "ErinTest"
      assert account.owner == nil
      assert account.type == "equity"
      assert account.uuid != nil

      assert balance.account_id == account.id
      assert balance.money.amount == 0
      assert balance.money.currency == :JPY
      assert balance.uuid != nil
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, :account, changeset, _} = Accounts.create_account(%{})
      refute changeset.valid?
    end

    test "new_acount/1 returns an account changeset" do
      changeset = Accounts.new_account()

      assert changeset != nil
    end

    test "update_account/2 with valid data updates the account" do
      account = insert(:account, owner: %{object: "Hubsynch.User", uid: "1234"})

      update_attrs = %{
        name: "NewName",
        owner: %{object: "HubIdentity.User", uid: "abc_123"},
        active: false
      }

      assert {:ok, %Account{} = account} = Accounts.update_account(account, update_attrs)
      assert account.active == false
      assert account.name == "NewName"
      assert account.owner.object == "HubIdentity.User"
      assert account.owner.uid == "abc_123"
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = insert(:account)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, %{name: nil})
    end
  end

  test "change_account/2 with valid data returns an account changeset" do
    account = insert(:account, owner: %{object: "Hubsynch.User", uid: "1234"})

    update_attrs = %{
      name: "NewName",
      owner: %{object: "HubIdentity.User", uid: "abc_123"},
      active: false
    }

    changeset = Accounts.change_account(account, update_attrs)
    assert changeset.valid?
    assert changeset.changes.name == "NewName"
    assert changeset.changes.owner.valid?
    assert changeset.changes.owner.changes == %{object: "HubIdentity.User", uid: "abc_123"}
    assert changeset.changes.active == false
  end

  describe "balances" do
    test "list_balances/0 returns all balances" do
      balance = insert(:balance)
      [found_balance] = Accounts.list_balances()
      assert found_balance.uuid == balance.uuid
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = insert(:balance)
      found_balance = Accounts.get_balance!(balance.id)
      assert found_balance.uuid == balance.uuid
    end

    test "update_balance/2 with valid data updates the balance" do
      balance = insert(:balance)
      new_money = Money.new(10_000, balance.money.currency)
      assert {:ok, %Balance{} = updated_balance} = Accounts.update_balance(balance, new_money)
      assert updated_balance.money == new_money
    end

    test "update_balance/2 with invalid data returns error changeset" do
      balance = insert(:balance)
      new_money = Money.new(10_000, "USD")
      assert {:error, changeset} = Accounts.update_balance(balance, new_money)
      assert changeset.errors[:money] == {"currency '%{currency}' must match", [currency: :JPY]}
    end
  end
end
