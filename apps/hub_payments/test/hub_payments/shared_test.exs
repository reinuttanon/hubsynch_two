defmodule HubPayments.SharedTest do
  use HubPayments.DataCase

  alias HubPayments.Shared

  describe "settings" do
    alias HubPayments.Shared.Setting

    @valid_attrs %{active: true, description: "some description", env: "development", key: "some key", type: "secret", value: "some value"}
    @update_attrs %{active: false, description: "some updated description", env: "staging", key: "some updated key", type: "file_path", value: "some updated value"}
    @invalid_attrs %{active: nil, description: nil, env: nil, key: nil, type: nil, value: nil}


    test "list_settings/0 returns all settings" do
      setting = insert(:setting)
      assert Shared.list_settings() == [setting]
    end

    test "get_setting!/1 returns the setting with given id" do
      setting = insert(:setting)
      assert Shared.get_setting!(setting.id) == setting
    end

    test "create_setting/1 with valid data creates a setting" do
      assert {:ok, %Setting{} = setting} = Shared.create_setting(@valid_attrs)
      assert setting.active == true
      assert setting.description == "some description"
      assert setting.env == "development"
      assert setting.key == "some key"
      assert setting.type == "secret"
      assert setting.value == "some value"
    end

    test "create_setting/1 with 2 active setting with the same key and env returns error" do
      setting_1 = insert(:setting)
      {:error, changeset} = Shared.create_setting(%{active: true, env: setting_1.env, key: setting_1.key, type: setting_1.type, value: setting_1.value})
      assert changeset.errors[:key] ==  {"has already been taken",
      [constraint: :unique, constraint_name: "settings_key_env_active_index"]}
    end

    test "create_setting/1 with 2 active setting with the same key on different env should succeed" do
      setting_1 = insert(:setting)

      envs = List.delete(Setting.envs, setting_1.env)
      for env <- envs do
        assert {:ok, %Setting{}} = Shared.create_setting(%{active: true, env: env, key: setting_1.key, type: setting_1.type, value: setting_1.value})
      end
    end

    test "create_setting/1 with 1 active, 1 inactive setting with the same key and env should succeed" do
      setting_1 = insert(:setting)
      assert {:ok, %Setting{}} = Shared.create_setting(%{active: !setting_1.active, env: setting_1.env, key: setting_1.key, type: setting_1.type, value: setting_1.value})
    end

    test "create_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shared.create_setting(@invalid_attrs)
    end

    test "create_setting/1 with valid enviroment data returns succeed" do
      for env <- Setting.envs do
        assert {:ok, %Setting{}} = Shared.create_setting(%{active: true, env: env, key: "key1", type: "secret", value: "value"})
      end

      assert {:error, error_changeset} = Shared.create_setting(%{active: true, env: "invalid_env", key: "key1", type: "secret", value: "value"})
      assert error_changeset.errors[:env] == {"is invalid", [validation: :inclusion, enum: ["development", "production", "staging"]]}
    end

    test "create_setting/1 with valid type data returns succeed" do
      for type <- Setting.types do
        assert {:ok, %Setting{}} = Shared.create_setting(%{active: true, env: "development", key: "key1#{type}", type: type, value: "value"})
      end

      assert {:error, error_changeset} = Shared.create_setting(%{active: true, env: "development", key: "key1", type: "invalid_type", value: "value"})

      assert error_changeset.errors[:type] == {"is invalid", [validation: :inclusion, enum: ["secret", "file_path", "url", "setting"]]}
    end

    test "update_setting/2 with valid data updates the setting" do
      setting = insert(:setting)
      assert {:ok, %Setting{} = setting} = Shared.update_setting(setting, @update_attrs)
      assert setting.active == false
      assert setting.description == "some updated description"
      assert setting.env == "staging"
      assert setting.key == "some updated key"
      assert setting.type == "file_path"
      assert setting.value == "some updated value"
    end

    test "update_setting/2 with invalid data returns error changeset" do
      setting = insert(:setting)
      assert {:error, %Ecto.Changeset{}} = Shared.update_setting(setting, @invalid_attrs)
      assert setting == Shared.get_setting!(setting.id)
    end

    test "delete_setting/1 deletes the setting" do
      setting = insert(:setting)
      assert {:ok, %Setting{}} = Shared.delete_setting(setting)
      assert_raise Ecto.NoResultsError, fn -> Shared.get_setting!(setting.id) end
    end

    test "change_setting/1 returns a setting changeset" do
      setting = insert(:setting)
      assert %Ecto.Changeset{} = Shared.change_setting(setting)
    end
  end
end
