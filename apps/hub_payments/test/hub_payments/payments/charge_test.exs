defmodule HubPayments.Payments.ChargeTest do
  use HubPayments.DataCase

  import HubPayments.Factory

  alias HubPayments.Payments.Charge

  describe "changeset/2" do
    test "returns a changeset with valid charge attributes" do
      provider = insert(:provider)
      credit_card = insert(:credit_card)

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          amount: 1000,
          currency: "JPY",
          credit_card_id: credit_card.id,
          provider_id: provider.id,
          reference: "some reference"
        })

      assert charge_changeset.valid?
      assert charge_changeset.changes.money == %Money{amount: 1000, currency: :JPY}
      assert charge_changeset.changes.credit_card_id == credit_card.id
      assert charge_changeset.changes.provider_id == provider.id
      assert charge_changeset.changes.uuid != nil
    end

    test "returns a error changeset with invvalid charge attributes" do
      provider = insert(:provider)
      credit_card = insert(:credit_card)

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          amount: 1000,
          currency: "invalid currency",
          credit_card_id: credit_card.id,
          provider_id: provider.id,
          reference: "some reference"
        })

      refute charge_changeset.valid?
      assert charge_changeset.errors[:money] == {"Invalid amount or currency", []}

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          amount: 1000,
          currency: "JPY",
          provider_id: provider.id,
          reference: "some reference"
        })

      refute charge_changeset.valid?

      assert charge_changeset.errors[:credit_card_id] ==
               {"can't be blank", [validation: :required]}

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          currency: "JPY",
          credit_card_id: credit_card.id,
          provider_id: provider.id,
          reference: "some reference"
        })

      refute charge_changeset.valid?
      assert charge_changeset.errors[:money] == {"can't be blank", [validation: :required]}

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          amount: 1000,
          currency: "JPY",
          provider_id: provider.id,
          reference: "some reference"
        })

      refute charge_changeset.valid?

      assert charge_changeset.errors[:credit_card_id] ==
               {"can't be blank", [validation: :required]}

      charge_changeset =
        Charge.changeset(%Charge{}, %{
          amount: 1000,
          currency: "JPY",
          credit_card_id: credit_card.id,
          reference: "some reference"
        })

      refute charge_changeset.valid?

      assert charge_changeset.errors[:provider_id] ==
               {"can't be blank", [validation: :required]}
    end
  end
end
