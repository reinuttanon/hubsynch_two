defmodule HubPayments.ProvidersTest do
  use HubPayments.DataCase

  alias HubPayments.Providers

  describe "providers" do
    alias HubPayments.Providers.Provider

    @valid_attrs %{active: true, credentials: %{}, name: "some name", url: "some url", uuid: "some uuid"}
    @update_attrs %{active: false, credentials: %{}, name: "some updated name", url: "some updated url", uuid: "some updated uuid"}
    @invalid_attrs %{active: nil, credentials: nil, name: nil, url: nil, uuid: nil}

    def provider_fixture(attrs \\ %{}) do
      {:ok, provider} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Providers.create_provider()

      provider
    end

    test "list_providers/0 returns all providers" do
      provider = provider_fixture()
      assert Providers.list_providers() == [provider]
    end

    test "get_provider!/1 returns the provider with given id" do
      provider = provider_fixture()
      assert Providers.get_provider!(provider.id) == provider
    end

    test "create_provider/1 with valid data creates a provider" do
      assert {:ok, %Provider{} = provider} = Providers.create_provider(@valid_attrs)
      assert provider.active == true
      assert provider.credentials == %{}
      assert provider.name == "some name"
      assert provider.url == "some url"
      assert provider.uuid == "some uuid"
    end

    test "create_provider/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Providers.create_provider(@invalid_attrs)
    end

    test "update_provider/2 with valid data updates the provider" do
      provider = provider_fixture()
      assert {:ok, %Provider{} = provider} = Providers.update_provider(provider, @update_attrs)
      assert provider.active == false
      assert provider.credentials == %{}
      assert provider.name == "some updated name"
      assert provider.url == "some updated url"
      assert provider.uuid == "some updated uuid"
    end

    test "update_provider/2 with invalid data returns error changeset" do
      provider = provider_fixture()
      assert {:error, %Ecto.Changeset{}} = Providers.update_provider(provider, @invalid_attrs)
      assert provider == Providers.get_provider!(provider.id)
    end

    test "delete_provider/1 deletes the provider" do
      provider = provider_fixture()
      assert {:ok, %Provider{}} = Providers.delete_provider(provider)
      assert_raise Ecto.NoResultsError, fn -> Providers.get_provider!(provider.id) end
    end

    test "change_provider/1 returns a provider changeset" do
      provider = provider_fixture()
      assert %Ecto.Changeset{} = Providers.change_provider(provider)
    end
  end

  describe "messages" do
    alias HubPayments.Providers.Message

    @valid_attrs %{data: %{}, owner: %{}, request: "some request", response: "some response", type: "some type"}
    @update_attrs %{data: %{}, owner: %{}, request: "some updated request", response: "some updated response", type: "some updated type"}
    @invalid_attrs %{data: nil, owner: nil, request: nil, response: nil, type: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Providers.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Providers.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Providers.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = Providers.create_message(@valid_attrs)
      assert message.data == %{}
      assert message.owner == %{}
      assert message.request == "some request"
      assert message.response == "some response"
      assert message.type == "some type"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Providers.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = Providers.update_message(message, @update_attrs)
      assert message.data == %{}
      assert message.owner == %{}
      assert message.request == "some updated request"
      assert message.response == "some updated response"
      assert message.type == "some updated type"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Providers.update_message(message, @invalid_attrs)
      assert message == Providers.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Providers.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Providers.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Providers.change_message(message)
    end
  end
end
