defmodule HubLedger.Accounts.AccountTest do
  use HubLedger.DataCase

  alias HubLedger.Accounts.Account

  describe "create_changeset/2" do
    test "returns a valid changeset" do
      attrs = %{currency: "JPY", name: "ErinTest", type: "equity"}
      changeset = Account.create_changeset(%Account{}, attrs)

      assert changeset.valid?
      assert changeset.changes[:currency] == "JPY"
      assert changeset.changes[:name] == "ErinTest"
      assert changeset.changes[:type] == "equity"
      assert changeset.changes[:kind] == "credit"
      assert changeset.changes[:uuid] != nil
    end

    test "with invalid currency returns error" do
      attrs = %{currency: "DDD", name: "ErinTest", type: "equity"}
      changeset = Account.create_changeset(%Account{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:currency] == {"is invalid", [{:validation, :required}]}

      attrs = %{name: "ErinTest", type: "equity"}
      changeset = Account.create_changeset(%Account{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:currency] == {"can't be blank", [{:validation, :required}]}
    end

    test "without name returns error" do
      attrs = %{currency: "JPY", type: "equity"}
      changeset = Account.create_changeset(%Account{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:name] == {"can't be blank", [{:validation, :required}]}
    end

    test "with invalid type returns error" do
      attrs = %{currency: "JPY", name: "ErinTest", type: "spaceship"}
      changeset = Account.create_changeset(%Account{}, attrs)

      refute changeset.valid?

      assert changeset.errors[:type] ==
               {"is invalid",
                [
                  validation: :inclusion,
                  enum: ["asset", "equity", "expense", "liability", "revenue"]
                ]}

      attrs = %{currency: "JPY", name: "ErinTest"}
      changeset = Account.create_changeset(%Account{}, attrs)

      refute changeset.valid?
      assert changeset.errors[:type] == {"can't be blank", [{:validation, :required}]}
    end
  end

  describe "update_changeset/2" do
    test "with valid attributes returns valid changeset" do
      account = insert(:account, owner: %{object: "Hubsynch.User", uid: "1234"})

      attrs = %{
        name: "NewName",
        owner: %{object: "HubIdentity.User", uid: "abc_123"},
        active: false
      }

      changeset = Account.update_changeset(account, attrs)
      assert changeset.valid?
      assert changeset.changes[:name] == "NewName"
      assert changeset.changes[:owner].changes == %{object: "HubIdentity.User", uid: "abc_123"}
      refute changeset.changes[:active]
    end

    test "does not update currency, kind, type or uuid" do
      account = insert(:account, %{type: "equity"})

      attrs = %{currency: "USD", kind: "debit", type: "asset", uuid: "new_uuid"}
      changeset = Account.update_changeset(account, attrs)
      assert changeset.valid?
      assert changeset.changes[:currency] != "USD"
      assert changeset.changes[:kind] != "debit"
      assert changeset.changes[:type] != "asset"
      assert changeset.changes[:uuid] != "new_uuid"
    end
  end
end
