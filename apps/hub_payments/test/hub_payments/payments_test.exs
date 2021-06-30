defmodule HubPayments.PaymentsTest do
  use HubPayments.DataCase

  alias HubPayments.Payments

  describe "charges" do
    alias HubPayments.Payments.Charge

    @update_attrs %{
      money: %{amount: 5000, currency: "JPY"},
      owner: %{},
      reference: "New reference"
    }
    @invalid_attrs %{
      credit_card_id: nil,
      provider_id: nil,
      money: nil
    }

    test "list_charges/0 returns all charges" do
      charge = insert(:charge)
      [found_charge] = Payments.list_charges()
      assert found_charge.id == charge.id
      assert found_charge.uuid == charge.uuid
    end

    test "get_charge!/1 returns the charge with given id" do
      charge = insert(:charge)
      found_charge = Payments.get_charge!(charge.id)
      assert found_charge.id == charge.id
      assert found_charge.uuid == charge.uuid
    end

    test "create_charge/1 with valid data creates a charge" do
      provider = insert(:provider)
      credit_card = insert(:credit_card)

      assert {:ok, %Charge{} = charge} =
               Payments.create_charge(%{
                 credit_card_id: credit_card.id,
                 money: %{amount: 100, currency: "JPY"},
                 owner: %{object: "User", uid: "1234"},
                 provider_id: provider.id,
                 reference: "reference-1"
               })

      assert charge.money == %Money{amount: 100, currency: :JPY}
      assert charge.owner == %HubPayments.Embeds.Owner{object: "User", uid: "1234"}
      assert DateTime.diff(charge.request_date, now()) < 10
      assert charge.reference == "reference-1"
      assert charge.provider_id == provider.id
      assert charge.uuid != nil
    end

    test "create_charge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_charge(@invalid_attrs)
    end

    test "update_charge/2 with valid data updates the charge" do
      charge = insert(:charge)
      assert {:ok, %Charge{} = updated_charge} = Payments.update_charge(charge, @update_attrs)
      assert updated_charge.money == %Money{amount: 5000, currency: :JPY}

      assert updated_charge.owner == %HubPayments.Embeds.Owner{
               object: "HubIdentity.User",
               uid: "user_12345678"
             }

      assert updated_charge.reference == "New reference"
      assert updated_charge.uuid == charge.uuid
    end

    test "update_charge/2 with invalid data returns error changeset" do
      charge = insert(:charge)
      assert {:error, %Ecto.Changeset{}} = Payments.update_charge(charge, @invalid_attrs)
    end

    test "delete_charge/1 deletes the charge" do
      charge = insert(:charge)
      assert {:ok, %Charge{}} = Payments.delete_charge(charge)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_charge!(charge.id) end
    end

    test "change_charge/1 returns a charge changeset" do
      charge = insert(:charge)
      assert %Ecto.Changeset{} = Payments.change_charge(charge)
    end
  end

  describe "points" do
    alias HubPayments.Payments.Point

    @update_attrs %{
      money: %{amount: 5000, currency: "HiP"},
      owner: %{object: "HubIdentity.User", uid: "user_12345678"}
    }
    @invalid_attrs %{
      money: nil
    }

    test "list_points/0 returns all points" do
      point = insert(:point)
      [found_point] = Payments.list_points()
      assert found_point.id == point.id
      assert found_point.uuid == point.uuid
    end

    test "get_point!/1 returns the point with given id" do
      point = insert(:point)
      found_point = Payments.get_point!(point.id)
      assert found_point.uuid == point.uuid
    end

    test "create_point/1 with valid data creates a point" do
      assert {:ok, %Point{} = point} =
               Payments.create_point(%{
                 money: %{amount: 10_000, currency: :JPY},
                 owner: %{object: "HubIdentity.User", uid: "user_12345678"}
               })

      assert point.money == %Money{amount: 10000, currency: :JPY}
      assert point.request_date == now()
      assert point.uuid != nil
    end

    test "create_point/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_point(@invalid_attrs)
    end

    test "update_point/2 with valid data updates the point" do
      point = insert(:point)
      assert {:ok, %Point{} = updated_point} = Payments.update_point(point, @update_attrs)
      assert updated_point.money == %Money{amount: 5000, currency: :HIP}

      assert updated_point.owner == %HubPayments.Embeds.Owner{
               object: "HubIdentity.User",
               uid: "user_12345678"
             }

      assert updated_point.uuid == point.uuid
    end

    test "update_point/2 with invalid data returns error changeset" do
      point = insert(:point)
      assert {:error, %Ecto.Changeset{}} = Payments.update_point(point, @invalid_attrs)
    end

    test "delete_point/1 deletes the point" do
      point = insert(:point)
      assert {:ok, %Point{}} = Payments.delete_point(point)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_point!(point.id) end
    end

    test "change_point/1 returns a point changeset" do
      point = insert(:point)
      assert %Ecto.Changeset{} = Payments.change_point(point)
    end
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
