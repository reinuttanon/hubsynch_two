defmodule HubPayments.Shared.SettingServerTest do
  use HubPayments.DataCase

  alias HubCluster.MementoRepo
  alias HubPayments.Shared.{SettingRecord, SettingServer}

  @records [
    %SettingRecord{key: "key1", env: "development", value: "value1"},
    %SettingRecord{key: "key2", env: "development", value: "value2"}
  ]

  setup do
    MementoRepo.clear(SettingRecord)

    @records
    |> Enum.each(&MementoRepo.insert(&1))
  end

  describe "list_settings/0" do
    test "returns all existing settings" do
      {:ok, records} = SettingServer.list_settings()
      assert records == @records
    end
  end

  describe "get_setting/2" do
    test "returns a setting with given key and env" do
      record = SettingServer.get_setting("key1", "development")
      assert record.value == "value1"
    end

    test "returns nil when given key and env do not match" do
      assert nil == SettingServer.get_setting("bad_key", "wrong_env")
    end
  end
end
