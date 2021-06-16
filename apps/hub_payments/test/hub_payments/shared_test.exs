defmodule HubPayments.SharedTest do
  use HubPayments.DataCase

  alias HubPayments.Shared

  describe "settings" do
    alias HubPayments.Shared.Setting

    @valid_attrs %{active: true, description: "some description", env: "some env", key: "some key", type: "some type", value: "some value"}
    @update_attrs %{active: false, description: "some updated description", env: "some updated env", key: "some updated key", type: "some updated type", value: "some updated value"}
    @invalid_attrs %{active: nil, description: nil, env: nil, key: nil, type: nil, value: nil}

    def setting_fixture(attrs \\ %{}) do
      {:ok, setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Shared.create_setting()

      setting
    end

    test "list_settings/0 returns all settings" do
      setting = setting_fixture()
      assert Shared.list_settings() == [setting]
    end

    test "get_setting!/1 returns the setting with given id" do
      setting = setting_fixture()
      assert Shared.get_setting!(setting.id) == setting
    end

    test "create_setting/1 with valid data creates a setting" do
      assert {:ok, %Setting{} = setting} = Shared.create_setting(@valid_attrs)
      assert setting.active == true
      assert setting.description == "some description"
      assert setting.env == "some env"
      assert setting.key == "some key"
      assert setting.type == "some type"
      assert setting.value == "some value"
    end

    test "create_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shared.create_setting(@invalid_attrs)
    end

    test "update_setting/2 with valid data updates the setting" do
      setting = setting_fixture()
      assert {:ok, %Setting{} = setting} = Shared.update_setting(setting, @update_attrs)
      assert setting.active == false
      assert setting.description == "some updated description"
      assert setting.env == "some updated env"
      assert setting.key == "some updated key"
      assert setting.type == "some updated type"
      assert setting.value == "some updated value"
    end

    test "update_setting/2 with invalid data returns error changeset" do
      setting = setting_fixture()
      assert {:error, %Ecto.Changeset{}} = Shared.update_setting(setting, @invalid_attrs)
      assert setting == Shared.get_setting!(setting.id)
    end

    test "delete_setting/1 deletes the setting" do
      setting = setting_fixture()
      assert {:ok, %Setting{}} = Shared.delete_setting(setting)
      assert_raise Ecto.NoResultsError, fn -> Shared.get_setting!(setting.id) end
    end

    test "change_setting/1 returns a setting changeset" do
      setting = setting_fixture()
      assert %Ecto.Changeset{} = Shared.change_setting(setting)
    end
  end
end
