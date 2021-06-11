defmodule HubCrm.HubsynchTest do
  use HubCrm.DataCase

  import HubCrm.HubsynchFactory

  alias HubCrm.Hubsynch

  describe "company_applications" do
    test "get_company_applications/1 returns the company_application" do
      company_application = insert(:company_application, %{app_code: "this1", site_id: "site123"})
      insert(:use_app, %{company_app_id: company_application.company_app_id})

      assert [company_application] ==
               Hubsynch.get_company_applications(%{app_code: "this1", site_id: "site123"})
    end

    test "get_company_application/1 returns [] when no record found" do
      assert [] == Hubsynch.get_company_applications(%{app_code: "not", site_id: "here"})
    end
  end

  describe "valid_application?" do
    test "valid_application?/1 returns true when the application exists" do
      company_application = insert(:company_application, %{app_code: "this1", site_id: "site123"})
      insert(:use_app, %{company_app_id: company_application.company_app_id})

      assert Hubsynch.valid_application?(%{app_code: "this1", site_id: "site123"})
    end

    test "valid_application?/1 returns false when the application does not exist" do
      refute Hubsynch.valid_application?(%{app_code: "not", site_id: "here"})
    end
  end

  describe "users" do
    alias HubCrm.Hubsynch.User

    @valid_attrs params_for(:user)
    @update_attrs %{first_name: "erin", last_name: "boeger"}
    @invalid_attrs %{sex: 5}

    test "list_users/0 returns all users" do
      user = insert(:user)
      [found] = Hubsynch.list_users()
      assert found.user_id == user.user_id
      assert found.hashid == user.hashid
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      found = Hubsynch.get_user!(user.user_id)
      assert found.user_id == user.user_id
      assert found.hashid == user.hashid
    end

    test "get_user/1 returns error with a string id" do
      assert Hubsynch.get_user("not id") == :error
    end

    test "user_exists?/1 returns true if the user exists" do
      user = insert(:user)
      assert Hubsynch.user_exists?(user.email)
    end

    test "user_exists?/1 returns false if the user does not exists" do
      refute Hubsynch.user_exists?("pickle.rick@citidel.com")
    end

    # test "create_user/1 with app_code and site_id injects the company_app_id" do
    #   company_application = insert(:company_application, %{app_code: "this1", site_id: "site123"})
    #   insert(:use_app, %{company_app_id: company_application.company_app_id})
    #
    #   params = %{
    #     "email" => "erin@hivelocity.co.jp",
    #     "password" => "password",
    #     "app_code" => "this1",
    #     "site_id" => "site123"
    #   }
    #
    #   assert {:ok, %User{} = user} = Hubsynch.create_user(params)
    #   assert user.activate_code != nil
    # end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Hubsynch.create_user(@valid_attrs)
      assert user.last_name == @valid_attrs[:last_name]
      assert user.first_name == @valid_attrs[:first_name]
    end

    #
    # test "create_user/1 hashes the password" do
    #   password = "password"
    #   user_params = Map.put(@valid_attrs, :password, password)
    #   {:ok, %User{} = user} = Hubsynch.create_user(user_params)
    #   assert user.password != password
    #   assert User.valid_password?(user, password)
    #   refute User.valid_password?(user, "wrongPassword")
    # end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hubsynch.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Hubsynch.update_user(user, @update_attrs)
      assert user.last_name == @update_attrs[:last_name]
      assert user.first_name == @update_attrs[:first_name]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Hubsynch.update_user(user, @invalid_attrs)
      found = Hubsynch.get_user!(user.user_id)
      assert found.user_id == user.user_id
      assert found.hashid == user.hashid
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Hubsynch.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Hubsynch.get_user!(user.user_id) end
    end
  end

  describe "address" do
    alias HubCrm.Hubsynch.{Address}

    @valid_attrs %{
      "address_1" => 2,
      "address_2" => "3 chome",
      "address_3" => "Hihoshi",
      "country" => 1,
      "zip_code" => "2230061"
    }
    @update_attrs %{"address_1" => 3, "address_2" => "4 chome"}
    @invalid_attrs %{"country" => nil, "zip_code" => nil}

    test "get_addresses/1 returns the all the users addresses" do
      user = insert(:user)

      for _ <- 1..3 do
        insert(:delivering_address, %{user_id: user.user_id})
        insert(:delivering_address)
      end

      addresses = Hubsynch.get_addresses(user.user_id)
      assert length(addresses) == 4
    end

    test "get_addresses/1 returns nil if no user" do
      user = insert(:user, %{delete_flag: "true"})

      for _ <- 1..3 do
        insert(:delivering_address, %{user_id: user.user_id})
        insert(:delivering_address)
      end

      assert [] = Hubsynch.get_addresses(user.user_id)
      assert [] = Hubsynch.get_addresses(555)
    end

    test "get_address/2 returns the address from the user" do
      user = insert(:user)
      insert(:delivering_address, %{user_id: user.user_id})
      address = Hubsynch.get_address(user.user_id, user.user_id)
      assert address.id == user.user_id
      assert address.user_id == user.user_id
    end

    test "get_address/2 returns the address from delivering_address" do
      user = insert(:user)
      delivering_address = insert(:delivering_address, %{user_id: user.user_id})
      address = Hubsynch.get_address(user.user_id, delivering_address.user_address_id)
      assert address.id == delivering_address.user_address_id
      assert address.user_id == delivering_address.user_id
    end

    test "get_address/2 returns nil if user_id does not match delivering_address user_id" do
      user = insert(:user)
      delivering_address = insert(:delivering_address, %{user_address_id: 555})
      refute user.user_id == delivering_address.user_id
      assert nil == Hubsynch.get_address(user.user_id, delivering_address.user_address_id)
    end

    test "get_address/2 returns nil if no address with the id" do
      user = insert(:user)
      assert nil == Hubsynch.get_address(user.user_id, 555)
      assert nil == Hubsynch.get_address(123, 555)
    end

    test "create_address/2 with valid params creates an address" do
      user = insert(:user)
      {:ok, address} = Hubsynch.create_address(user, @valid_attrs)
      assert address.address_1 == @valid_attrs["address_1"]
      assert address.country == @valid_attrs["country"]
      assert address.zip_code == @valid_attrs["zip_code"]
      assert address.user_id == user.user_id
      refute address.id == user.user_id
    end

    test "create_address/1 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Hubsynch.create_address(user, @invalid_attrs)
    end

    test "update_address/3 with valid params updates the users address" do
      user = insert(:user)
      insert(:delivering_address, %{user_id: user.user_id})

      assert {:ok, %Address{} = address} =
               Hubsynch.update_address(
                 user.user_id,
                 user.user_id,
                 @update_attrs
               )

      assert address.address_1 == @update_attrs["address_1"]
      assert address.address_2 == @update_attrs["address_2"]
      assert address.id == user.user_id
    end

    test "update_address/3 with invalid params for a user address returns changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Hubsynch.update_address(
                 user.user_id,
                 user.user_id,
                 @invalid_attrs
               )

      assert changeset.errors[:country] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:zip_code] == {"can't be blank", [validation: :required]}
    end

    test "update_address/3 with valid params updates the users delivering_address" do
      user = insert(:user)
      address_attrs = Map.put(@valid_attrs, "user_id", user.user_id)
      {:ok, address} = Hubsynch.create_address(user, address_attrs)

      assert {:ok, %Address{} = updated} =
               Hubsynch.update_address(
                 user.user_id,
                 address.id,
                 @update_attrs
               )

      assert updated.address_1 == @update_attrs["address_1"]
      assert updated.address_2 == @update_attrs["address_2"]
      assert updated.id == address.id
    end

    test "update_address/3 with invalid params for a delivering_address returns changeset" do
      user = insert(:user)
      address_attrs = Map.put(@valid_attrs, "user_id", user.user_id)
      {:ok, address} = Hubsynch.create_address(user, address_attrs)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Hubsynch.update_address(
                 user.user_id,
                 address.id,
                 @invalid_attrs
               )

      assert changeset.errors[:country] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:zip_code] == {"can't be blank", [validation: :required]}
    end
  end
end
