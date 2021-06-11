defmodule HubPayments.WalletsTest do
  use HubPayments.DataCase

  alias HubPayments.Wallets

  describe "wallets" do
    alias HubPayments.Wallets.Wallet

    @valid_attrs %{owner: %{}, prefered_credit_card_uuid: "some prefered_credit_card_uuid", uuid: "some uuid"}
    @update_attrs %{owner: %{}, prefered_credit_card_uuid: "some updated prefered_credit_card_uuid", uuid: "some updated uuid"}
    @invalid_attrs %{owner: nil, prefered_credit_card_uuid: nil, uuid: nil}

    def wallet_fixture(attrs \\ %{}) do
      {:ok, wallet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Wallets.create_wallet()

      wallet
    end

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Wallets.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Wallets.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with valid data creates a wallet" do
      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(@valid_attrs)
      assert wallet.owner == %{}
      assert wallet.prefered_credit_card_uuid == "some prefered_credit_card_uuid"
      assert wallet.uuid == "some uuid"
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{} = wallet} = Wallets.update_wallet(wallet, @update_attrs)
      assert wallet.owner == %{}
      assert wallet.prefered_credit_card_uuid == "some updated prefered_credit_card_uuid"
      assert wallet.uuid == "some updated uuid"
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_wallet(wallet, @invalid_attrs)
      assert wallet == Wallets.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Wallets.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Wallets.get_wallet!(wallet.id) end
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Wallets.change_wallet(wallet)
    end
  end

  describe "credit_cards" do
    alias HubPayments.Wallets.CreditCard

    @valid_attrs %{brand: "some brand", exp_month: "some exp_month", exp_year: "some exp_year", fingerprint: "some fingerprint", last_four: "some last_four", uuid: "some uuid"}
    @update_attrs %{brand: "some updated brand", exp_month: "some updated exp_month", exp_year: "some updated exp_year", fingerprint: "some updated fingerprint", last_four: "some updated last_four", uuid: "some updated uuid"}
    @invalid_attrs %{brand: nil, exp_month: nil, exp_year: nil, fingerprint: nil, last_four: nil, uuid: nil}

    def credit_card_fixture(attrs \\ %{}) do
      {:ok, credit_card} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Wallets.create_credit_card()

      credit_card
    end

    test "list_credit_cards/0 returns all credit_cards" do
      credit_card = credit_card_fixture()
      assert Wallets.list_credit_cards() == [credit_card]
    end

    test "get_credit_card!/1 returns the credit_card with given id" do
      credit_card = credit_card_fixture()
      assert Wallets.get_credit_card!(credit_card.id) == credit_card
    end

    test "create_credit_card/1 with valid data creates a credit_card" do
      assert {:ok, %CreditCard{} = credit_card} = Wallets.create_credit_card(@valid_attrs)
      assert credit_card.brand == "some brand"
      assert credit_card.exp_month == "some exp_month"
      assert credit_card.exp_year == "some exp_year"
      assert credit_card.fingerprint == "some fingerprint"
      assert credit_card.last_four == "some last_four"
      assert credit_card.uuid == "some uuid"
    end

    test "create_credit_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_credit_card(@invalid_attrs)
    end

    test "update_credit_card/2 with valid data updates the credit_card" do
      credit_card = credit_card_fixture()
      assert {:ok, %CreditCard{} = credit_card} = Wallets.update_credit_card(credit_card, @update_attrs)
      assert credit_card.brand == "some updated brand"
      assert credit_card.exp_month == "some updated exp_month"
      assert credit_card.exp_year == "some updated exp_year"
      assert credit_card.fingerprint == "some updated fingerprint"
      assert credit_card.last_four == "some updated last_four"
      assert credit_card.uuid == "some updated uuid"
    end

    test "update_credit_card/2 with invalid data returns error changeset" do
      credit_card = credit_card_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_credit_card(credit_card, @invalid_attrs)
      assert credit_card == Wallets.get_credit_card!(credit_card.id)
    end

    test "delete_credit_card/1 deletes the credit_card" do
      credit_card = credit_card_fixture()
      assert {:ok, %CreditCard{}} = Wallets.delete_credit_card(credit_card)
      assert_raise Ecto.NoResultsError, fn -> Wallets.get_credit_card!(credit_card.id) end
    end

    test "change_credit_card/1 returns a credit_card changeset" do
      credit_card = credit_card_fixture()
      assert %Ecto.Changeset{} = Wallets.change_credit_card(credit_card)
    end
  end
end
