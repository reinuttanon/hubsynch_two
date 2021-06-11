defmodule HubCrm.IdentitiesTest do
  use HubCrm.DataCase

  alias HubCrm.Identities

  describe "users" do
    alias HubCrm.Identities.User

    @valid_attrs %{first_name: "some first_name", first_name_kana: "some first_name_kana", first_name_roman: "some first_name_roman", gender: "some gender", hub_identity_uid: "some hub_identity_uid", last_name: "some last_name", last_name_kana: "some last_name_kana", last_name_roman: "some last_name_roman", occupation: "some occupation"}
    @update_attrs %{first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", first_name_roman: "some updated first_name_roman", gender: "some updated gender", hub_identity_uid: "some updated hub_identity_uid", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", last_name_roman: "some updated last_name_roman", occupation: "some updated occupation"}
    @invalid_attrs %{first_name: nil, first_name_kana: nil, first_name_roman: nil, gender: nil, hub_identity_uid: nil, last_name: nil, last_name_kana: nil, last_name_roman: nil, occupation: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Identities.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Identities.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Identities.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Identities.create_user(@valid_attrs)
      assert user.first_name == "some first_name"
      assert user.first_name_kana == "some first_name_kana"
      assert user.first_name_roman == "some first_name_roman"
      assert user.gender == "some gender"
      assert user.hub_identity_uid == "some hub_identity_uid"
      assert user.last_name == "some last_name"
      assert user.last_name_kana == "some last_name_kana"
      assert user.last_name_roman == "some last_name_roman"
      assert user.occupation == "some occupation"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Identities.update_user(user, @update_attrs)
      assert user.first_name == "some updated first_name"
      assert user.first_name_kana == "some updated first_name_kana"
      assert user.first_name_roman == "some updated first_name_roman"
      assert user.gender == "some updated gender"
      assert user.hub_identity_uid == "some updated hub_identity_uid"
      assert user.last_name == "some updated last_name"
      assert user.last_name_kana == "some updated last_name_kana"
      assert user.last_name_roman == "some updated last_name_roman"
      assert user.occupation == "some updated occupation"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Identities.update_user(user, @invalid_attrs)
      assert user == Identities.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Identities.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Identities.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Identities.change_user(user)
    end
  end

  describe "addresses" do
    alias HubCrm.Identities.Address

    @valid_attrs %{address_1: "some address_1", address_2: "some address_2", address_3: "some address_3", address_4: "some address_4", address_5: "some address_5", country: "some country", default: true, postal_code: "some postal_code"}
    @update_attrs %{address_1: "some updated address_1", address_2: "some updated address_2", address_3: "some updated address_3", address_4: "some updated address_4", address_5: "some updated address_5", country: "some updated country", default: false, postal_code: "some updated postal_code"}
    @invalid_attrs %{address_1: nil, address_2: nil, address_3: nil, address_4: nil, address_5: nil, country: nil, default: nil, postal_code: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Identities.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Identities.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Identities.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Identities.create_address(@valid_attrs)
      assert address.address_1 == "some address_1"
      assert address.address_2 == "some address_2"
      assert address.address_3 == "some address_3"
      assert address.address_4 == "some address_4"
      assert address.address_5 == "some address_5"
      assert address.country == "some country"
      assert address.default == true
      assert address.postal_code == "some postal_code"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Identities.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Identities.update_address(address, @update_attrs)
      assert address.address_1 == "some updated address_1"
      assert address.address_2 == "some updated address_2"
      assert address.address_3 == "some updated address_3"
      assert address.address_4 == "some updated address_4"
      assert address.address_5 == "some updated address_5"
      assert address.country == "some updated country"
      assert address.default == false
      assert address.postal_code == "some updated postal_code"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Identities.update_address(address, @invalid_attrs)
      assert address == Identities.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Identities.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Identities.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Identities.change_address(address)
    end
  end
end
