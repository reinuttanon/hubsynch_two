defmodule HubPayments.PaymentsTest do
  use HubPayments.DataCase

  alias HubPayments.Payments

  describe "charges" do
    alias HubPayments.Payments.Charge

    @valid_attrs %{
      money: %{amount: 1000, currency: "JPY"},
      owner: %{},
      process_date: "2010-04-17T14:00:00Z",
      reference: "some reference",
      request_date: "2010-04-17T14:00:00Z",
      settle_date: "2010-04-17T14:00:00Z",
      uuid: "some uid"
    }
    @update_attrs %{
      money: %{amount: 5000, currency: "JPY"},
      owner: %{},
      process_date: "2011-05-18T15:01:01Z",
      reference: "some updated reference",
      request_date: "2011-05-18T15:01:01Z",
      settle_date: "2011-05-18T15:01:01Z",
      uuid: "some updated uuid"
    }
    @invalid_attrs %{
      money: nil,
      owner: nil,
      process_date: nil,
      reference: nil,
      request_date: nil,
      settle_date: nil,
      uuid: nil
    }

    def charge_fixture(attrs \\ %{}) do
      {:ok, charge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_charge()

      charge
    end

    test "list_charges/0 returns all charges" do
      charge = charge_fixture()
      assert Payments.list_charges() == [charge]
    end

    test "get_charge!/1 returns the charge with given id" do
      charge = charge_fixture()
      assert Payments.get_charge!(charge.id) == charge
    end

    test "create_charge/1 with valid data creates a charge" do
      assert {:ok, %Charge{} = charge} = Payments.create_charge(@valid_attrs)

      assert charge.money == %Money{amount: 1000, currency: :JPY}
      assert charge.owner == %{}

      assert charge.process_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert charge.reference == "some reference"
      assert charge.request_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert charge.settle_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert charge.uuid == "some uid"
    end

    test "create_charge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_charge(@invalid_attrs)
    end

    test "update_charge/2 with valid data updates the charge" do
      charge = charge_fixture()
      assert {:ok, %Charge{} = charge} = Payments.update_charge(charge, @update_attrs)
      assert charge.money == %Money{amount: 5000, currency: :JPY}
      assert charge.owner == %{}
      assert charge.process_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert charge.reference == "some updated reference"
      assert charge.request_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert charge.settle_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert charge.uuid == "some updated uuid"
    end

    test "update_charge/2 with invalid data returns error changeset" do
      charge = charge_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_charge(charge, @invalid_attrs)
      assert charge == Payments.get_charge!(charge.id)
    end

    test "delete_charge/1 deletes the charge" do
      charge = charge_fixture()
      assert {:ok, %Charge{}} = Payments.delete_charge(charge)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_charge!(charge.id) end
    end

    test "change_charge/1 returns a charge changeset" do
      charge = charge_fixture()
      assert %Ecto.Changeset{} = Payments.change_charge(charge)
    end
  end

  describe "points" do
    alias HubPayments.Payments.Point

    @valid_attrs %{
      money: %{amount: 1000, currency: "HiP"},
      owner: %{},
      process_date: "2010-04-17T14:00:00Z",
      reference: "some reference",
      request_date: "2010-04-17T14:00:00Z",
      settle_date: "2010-04-17T14:00:00Z",
      uuid: "some uuid"
    }
    @update_attrs %{
      money: %{amount: 5000, currency: "HiP"},
      owner: %{},
      process_date: "2011-05-18T15:01:01Z",
      reference: "some updated reference",
      request_date: "2011-05-18T15:01:01Z",
      settle_date: "2011-05-18T15:01:01Z",
      uuid: "some updated uuid"
    }
    @invalid_attrs %{
      money: nil,
      owner: nil,
      process_date: nil,
      reference: nil,
      request_date: nil,
      settle_date: nil,
      uuid: nil
    }

    def point_fixture(attrs \\ %{}) do
      {:ok, point} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Payments.create_point()

      point
    end

    test "list_points/0 returns all points" do
      point = point_fixture()
      assert Payments.list_points() == [point]
    end

    test "get_point!/1 returns the point with given id" do
      point = point_fixture()
      assert Payments.get_point!(point.id) == point
    end

    test "create_point/1 with valid data creates a point" do
      assert {:ok, %Point{} = point} = Payments.create_point(@valid_attrs)
      assert point.money == %Money{amount: 1000, currency: :HIP}
      assert point.owner == %{}
      assert point.process_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert point.reference == "some reference"
      assert point.request_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert point.settle_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert point.uuid == "some uuid"
    end

    test "create_point/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_point(@invalid_attrs)
    end

    test "update_point/2 with valid data updates the point" do
      point = point_fixture()
      assert {:ok, %Point{} = point} = Payments.update_point(point, @update_attrs)
      assert point.money == %Money{amount: 5000, currency: :HIP}
      assert point.owner == %{}
      assert point.process_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert point.reference == "some updated reference"
      assert point.request_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert point.settle_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert point.uuid == "some updated uuid"
    end

    test "update_point/2 with invalid data returns error changeset" do
      point = point_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_point(point, @invalid_attrs)
      assert point == Payments.get_point!(point.id)
    end

    test "delete_point/1 deletes the point" do
      point = point_fixture()
      assert {:ok, %Point{}} = Payments.delete_point(point)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_point!(point.id) end
    end

    test "change_point/1 returns a point changeset" do
      point = point_fixture()
      assert %Ecto.Changeset{} = Payments.change_point(point)
    end
  end
end
