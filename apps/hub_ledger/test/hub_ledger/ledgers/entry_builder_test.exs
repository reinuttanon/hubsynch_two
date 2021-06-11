defmodule HubLedger.Ledgers.EntryBuilderTest do
  use HubLedger.DataCase

  alias HubLedger.Ledgers.EntryBuilder

  describe "changeset/2" do
    test "with valid data returns changeset" do
      string_config = %{entry: "entry", transactions: [%{one: "one"}]} |> Jason.encode!()

      changeset =
        EntryBuilder.changeset(%EntryBuilder{}, %{name: "builder", string_config: string_config})

      assert changeset.valid?

      assert changeset.changes[:name] == "builder"

      assert changeset.changes[:json_config] == %{
               "entry" => "entry",
               "transactions" => [%{"one" => "one"}]
             }
    end

    test "with invalid data returns error tuple" do
      changeset = EntryBuilder.changeset(%EntryBuilder{}, %{})

      refute changeset.valid?
      assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:json_config] == {"can't be blank", [validation: :required]}
    end

    test "with invalid json_config returns error" do
      changeset = EntryBuilder.changeset(%EntryBuilder{}, %{string_config: "noooupe!"})

      refute changeset.valid?
      assert changeset.errors[:json_config] == {"is invalid JSON", [validation: :required]}
    end
  end
end
