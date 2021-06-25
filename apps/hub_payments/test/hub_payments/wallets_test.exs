defmodule HubPayments.WalletsTest do
  use HubPayments.DataCase

  alias HubPayments.Wallets

  describe "list_wallets/0" do
    test "returns all wallets" do
      new_wallet = insert(:wallet)
      [wallet] = Wallets.list_wallets()

      assert new_wallet == wallet
    end
  end

  describe "get_wallet!/1" do
    test "returns the wallet with given id" do
      new_wallet = insert(:wallet)
      wallet = Wallets.get_wallet!(new_wallet.id)

      assert new_wallet == wallet
    end
  end

  describe "create_wallet/1" do
    test "with valid data creates a wallet" do
      owner = build(:owner)

      {:ok, wallet} =
        Wallets.create_wallet(%{prefered_credit_card_uuid: "some_card_uuid", owner: owner})

      assert wallet.prefered_credit_card_uuid == "some_card_uuid"
      assert wallet.owner.object == owner.object
      assert wallet.owner.uid == owner.uid
      assert wallet.uuid != nil
    end
  end

  describe "update_wallet/2" do
    test "with valid data creates a wallet" do
      wallet = insert(:wallet)
      new_owner = build(:owner, object: "another_object", uid: "another_uid")

      {:ok, updated_wallet} =
        Wallets.update_wallet(wallet, %{
          prefered_credit_card_uuid: "new_card_uuid",
          owner: new_owner
        })

      assert updated_wallet.prefered_credit_card_uuid == "new_card_uuid"
      assert updated_wallet.owner.object == "another_object"
      assert updated_wallet.owner.uid == "another_uid"
      assert updated_wallet.uuid == wallet.uuid
    end
  end

  describe "delete_wallet/1" do
    test "with valid data deletes a wallet" do
      wallet = insert(:wallet)

      {:ok, deleted_wallet} = Wallets.delete_wallet(wallet)

      assert deleted_wallet.uuid == wallet.uuid
      assert Wallets.list_wallets() == []
    end
  end

  describe "change_wallet/2" do
    test "returns a wallet changeset" do
      wallet = insert(:wallet)
      new_owner = build(:owner, object: "another_object", uid: "another_uid")

      assert %Ecto.Changeset{} =
               Wallets.change_wallet(wallet, %{
                 prefered_credit_card_uuid: "new_card_uuid",
                 owner: new_owner
               })
    end
  end

  describe "list_credit_cards/0" do
    test "returns all credit cards" do
      credit_card = insert(:credit_card)
      [found_credit_card] = Wallets.list_credit_cards()

      assert found_credit_card.uuid == credit_card.uuid
    end
  end

  describe "get_credit_cards!/1" do
    test "returns the credit_cards with given id" do
      credit_card = insert(:credit_card)
      found_credit_card = Wallets.get_credit_card!(credit_card.id)

      assert found_credit_card.uuid == credit_card.uuid
    end
  end

  describe "get_credit_cards/1" do
    test "with valid uuid and owner returns the card" do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, wallet: wallet)
      found_card = Wallets.get_credit_card(%{uuid: credit_card.uuid, owner: wallet.owner})
      assert found_card.id == credit_card.id
    end

    test "with invalid uuid returns nil" do
      wallet = insert(:wallet)
      assert Wallets.get_credit_card(%{uuid: "invalid_uuid", owner: wallet.owner}) == nil
    end

    test "with invalid owner returns nil" do
      wallet = insert(:wallet)
      credit_card = insert(:credit_card, wallet: wallet)

      assert Wallets.get_credit_card(%{
               uuid: credit_card.uuid,
               owner: %{object: "HubIdentity.User", uid: "wrong_uuid"}
             }) == nil
    end
  end

  describe "create_credit_cards/1" do
    test "with valid data creates a credit_cards" do
      wallet = insert(:wallet)

      assert {:ok, credit_card} =
               Wallets.create_credit_card(%{
                 brand: "visa",
                 exp_month: "01",
                 exp_year: String.slice("#{DateTime.utc_now().year}", -2..-1),
                 fingerprint: "some_fingerprint",
                 last_four: "1111",
                 vault_uuid: "some_vault_uuid",
                 wallet_id: wallet.id
               })

      assert credit_card.brand == "visa"
      assert credit_card.exp_month == "01"
      assert credit_card.exp_year == String.slice("#{DateTime.utc_now().year}", -2..-1)
      assert credit_card.fingerprint == "some_fingerprint"
      assert credit_card.last_four == "1111"
      assert credit_card.vault_uuid == "some_vault_uuid"
      assert credit_card.wallet_id == wallet.id
      assert credit_card.uuid != nil
    end

    test "with invalid data returns error" do
      wallet = insert(:wallet)

      {:error, credit_card} =
        Wallets.create_credit_card(%{
          brand: "visa",
          exp_month: "month",
          exp_year: String.slice("#{DateTime.utc_now().year}", -2..-1),
          fingerprint: "some_fingerprint",
          last_four: "1111",
          vault_uuid: "some_vault_uuid",
          wallet_id: wallet.id
        })

      refute credit_card.valid?

      assert credit_card.errors == [
               {
                 :exp_month,
                 {
                   "is invalid",
                   [
                     {:validation, :inclusion},
                     {:enum,
                      ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]}
                   ]
                 }
               },
               {:exp_month,
                {"should be %{count} character(s)",
                 [count: 2, validation: :length, kind: :is, type: :string]}}
             ]

      {:error, credit_card} =
        Wallets.create_credit_card(%{
          brand: "visa",
          exp_month: "13",
          exp_year: String.slice("#{DateTime.utc_now().year}", -2..-1),
          fingerprint: "some_fingerprint",
          last_four: "1111",
          vault_uuid: "some_vault_uuid",
          wallet_id: wallet.id
        })

      refute credit_card.valid?

      assert credit_card.errors == [
               exp_month: {
                 "is invalid",
                 [
                   validation: :inclusion,
                   enum: ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
                 ]
               }
             ]

      {:error, credit_card} =
        Wallets.create_credit_card(%{
          brand: "visa",
          exp_month: "12",
          exp_year: "year",
          fingerprint: "some_fingerprint",
          last_four: "1111",
          vault_uuid: "some_vault_uuid",
          wallet_id: wallet.id
        })

      refute credit_card.valid?

      assert credit_card.errors[:exp_year] ==
               {"should be %{count} character(s)",
                [count: 2, validation: :length, kind: :is, type: :string]}
    end
  end

  describe "update_credit_card/2" do
    test "with valid data updates a credit card" do
      credit_card = insert(:credit_card)
      wallet = insert(:wallet)

      {:ok, updated_credit_card} =
        Wallets.update_credit_card(credit_card, %{
          brand: "master_card",
          exp_month: "12",
          exp_year: String.slice("#{DateTime.utc_now().year}", -2..-1),
          fingerprint: "updated_fingerprint",
          last_four: "4444",
          vault_uuid: "updated_vault_uuid",
          wallet_id: wallet.id
        })

      assert updated_credit_card.brand == "master_card"
      assert updated_credit_card.exp_month == "12"
      assert updated_credit_card.exp_year == String.slice("#{DateTime.utc_now().year}", -2..-1)
      assert updated_credit_card.fingerprint == "updated_fingerprint"
      assert updated_credit_card.last_four == "4444"
      assert updated_credit_card.vault_uuid == "updated_vault_uuid"
      assert updated_credit_card.wallet_id == wallet.id
      assert updated_credit_card.uuid != nil
    end

    test "with invalid data returns error changeset" do
      credit_card = insert(:credit_card)

      assert {:error, %Ecto.Changeset{}} =
               Wallets.update_credit_card(credit_card, %{
                 brand: nil,
                 exp_month: nil,
                 exp_year: nil
               })
    end
  end

  describe "delete_credit_card/1" do
    test "with valid data deletes a credit_card" do
      credit_card = insert(:credit_card)

      {:ok, deleted_credit_card} = Wallets.delete_credit_card(credit_card)

      assert deleted_credit_card.uuid == credit_card.uuid
      assert Wallets.list_credit_cards() == []
    end
  end

  describe "change_credit_card/2" do
    test "returns a credit_card changeset" do
      credit_card = insert(:credit_card)
      wallet = insert(:wallet)

      assert %Ecto.Changeset{} =
               Wallets.change_credit_card(credit_card, %{
                 brand: "master_card",
                 exp_month: "12",
                 exp_year: String.slice("#{DateTime.utc_now().year}", -2..-1),
                 fingerprint: "updated_fingerprint",
                 last_four: "4444",
                 vault_uuid: "updated_vault_uuid",
                 wallet_id: wallet.id
               })
    end
  end
end
