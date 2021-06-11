defmodule HubLedger.Ledgers.EntryTest do
  use HubLedger.DataCase

  alias HubLedger.Ledgers.Entry

  describe "create_changeset/1" do
    test "with valid attrs returns valid changeset" do
      attrs = %{
        description: "this is my entry, there are many others, but this one is mine",
        owner: %{type: "sunshine", uid: "m16"}
      }

      changeset = Entry.create_changeset(attrs)
      assert changeset.valid?
      assert changeset.changes.owner.valid?
    end
  end
end
