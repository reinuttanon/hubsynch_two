defmodule HubPayments.ClientServicesTest do
  use HubPayments.DataCase

  alias HubPayments.ClientServices

  describe "payment_configs" do
    alias HubPayments.ClientServices.PaymentConfig

    @update_attrs %{
      client_service_uuid: "some updated client_service_uuid",
      payment_methods: ["points"],
      statement_name: "some updated statement_name"
    }
    @invalid_attrs %{
      client_service_uuid: nil,
      payment_methods: nil
    }

    test "list_payment_configs/0 returns all payment_configs" do
      payment_config = insert(:payment_config)
      [found_payment_config] = ClientServices.list_payment_configs()
      assert found_payment_config.uuid == payment_config.uuid
    end

    test "get_payment_config!/1 returns the payment_config with given id" do
      payment_config = insert(:payment_config)
      found_payment_config = ClientServices.get_payment_config!(payment_config.id)
      assert found_payment_config.uuid == payment_config.uuid
    end

    test "create_payment_config/1 with valid data creates a payment_config" do
      assert {:ok, %PaymentConfig{} = payment_config} =
               ClientServices.create_payment_config(params_for(:payment_config))

      assert payment_config.client_service_uuid == "hub_identity_client_service_uid"
      assert payment_config.payment_methods == ["credit_card"]
      assert payment_config.statement_name == "some statement name"
      assert payment_config.uuid =~ "payment_config_"
    end

    test "create_payment_config/1 with invalid data returns error changeset" do
      {:error, %Ecto.Changeset{} = changeset} =
        ClientServices.create_payment_config(@invalid_attrs)

      assert changeset.errors[:client_service_uuid] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:payment_methods] == {"can't be blank", [validation: :required]}
    end

    test "create_payment_config/1 with empty list for payment methods returns error changeset" do
      {:error, %Ecto.Changeset{} = changeset} =
        ClientServices.create_payment_config(%{payment_methods: []})

      assert changeset.errors[:payment_methods] ==
               {"should have at least %{count} item(s)",
                [{:count, 1}, {:validation, :length}, {:kind, :min}, {:type, :list}]}
    end

    test "create_payment_config/1 with invalid payment method returns error changeset" do
      {:error, %Ecto.Changeset{} = changeset} =
        ClientServices.create_payment_config(%{payment_methods: ["cats"]})

      assert changeset.errors[:payment_methods] ==
               {"has an invalid entry", [validation: :subset, enum: ["credit_card", "points"]]}
    end

    test "update_payment_config/2 with valid data updates the payment_config" do
      payment_config = insert(:payment_config)

      assert {:ok, %PaymentConfig{} = updated_payment_config} =
               ClientServices.update_payment_config(payment_config, @update_attrs)

      assert updated_payment_config.client_service_uuid == "some updated client_service_uuid"
      assert updated_payment_config.payment_methods == ["points"]
      assert updated_payment_config.statement_name == "some updated statement_name"
      assert updated_payment_config.uuid == payment_config.uuid
    end

    test "update_payment_config/2 with invalid data returns error changeset" do
      payment_config = insert(:payment_config)

      assert {:error, %Ecto.Changeset{}} =
               ClientServices.update_payment_config(payment_config, @invalid_attrs)
    end

    test "update_payment_config/2 with empty list for payment methods returns error changeset" do
      payment_config = insert(:payment_config)

      {:error, %Ecto.Changeset{} = changeset} =
        ClientServices.update_payment_config(payment_config, %{payment_methods: []})

      assert changeset.errors[:payment_methods] ==
               {"should have at least %{count} item(s)",
                [{:count, 1}, {:validation, :length}, {:kind, :min}, {:type, :list}]}
    end

    test "update_payment_config/2 with invalid payment method returns error changeset" do
      payment_config = insert(:payment_config)

      {:error, %Ecto.Changeset{} = changeset} =
        ClientServices.update_payment_config(payment_config, %{payment_methods: ["cats"]})

      assert changeset.errors[:payment_methods] ==
               {"has an invalid entry", [validation: :subset, enum: ["credit_card", "points"]]}
    end

    test "delete_payment_config/1 soft deletes the payment_config" do
      payment_config = insert(:payment_config)
      assert {:ok, %PaymentConfig{}} = ClientServices.delete_payment_config(payment_config)

      deleted_payment_config = ClientServices.get_payment_config!(payment_config.id)
      assert deleted_payment_config.deleted_at != nil
    end

    test "change_payment_config/1 returns a payment_config changeset" do
      payment_config = insert(:payment_config)
      assert %Ecto.Changeset{} = ClientServices.change_payment_config(payment_config)
    end
  end
end
