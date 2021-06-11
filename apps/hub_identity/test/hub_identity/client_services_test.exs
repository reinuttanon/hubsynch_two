defmodule HubIdentity.ClientServicesTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Administration
  alias HubIdentity.ClientServices
  alias HubIdentity.ClientServices.{ApiKey, ClientService}
  alias HubIdentity.Repo

  describe "client_services" do
    @valid_attrs params_for(:client_service)
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      redirect_url: "some updated redirect_url",
      url: "some updated url",
      logo: "some updated logo",
      email_confirmation_redirect_url: "some updated confirmation url",
      pass_change_redirect_url: "some updated password change redirect url"
    }
    @invalid_attrs %{
      description: nil,
      name: nil,
      redirect_url: nil,
      url: nil,
      email_confirmation_redirect_url: nil
    }

    test "list_client_services/0 returns all client_services" do
      client_service = insert(:client_service)
      [found] = ClientServices.list_client_services()
      assert found.uid == client_service.uid
    end

    test "list_client_services/1 with ids: true returns all client_service ids" do
      for _ <- 1..3 do
        insert(:client_service)
      end

      ids = ClientServices.list_client_services(%{ids: true})
      assert length(ids) == 3
      assert is_integer(hd(ids))
    end

    test "list_client_services/1 with ids: true and administrator_id returns all client_service ids" do
      administrator = insert(:administrator)

      for _ <- 1..3 do
        insert(:client_service)
        insert(:client_service, %{administrators: [administrator]})
      end

      ids = ClientServices.list_client_services(%{administrator_id: administrator.id, ids: true})
      assert length(ids) == 3
      assert is_integer(hd(ids))
    end

    test "list_client_services with an administrator id returns all client_services for the admin" do
      administrator = insert(:administrator)

      for _ <- 1..3 do
        ClientServices.create_client_service(@valid_attrs, administrator)
        admin_2 = insert(:administrator)
        ClientServices.create_client_service(@valid_attrs, admin_2)
      end

      client_services = ClientServices.list_client_services(%{administrator_id: administrator.id})
      assert length(client_services) == 3
    end

    test "get_client_service!/1 returns the client_service with given id" do
      client_service = insert(:client_service)
      found = ClientServices.get_client_service!(client_service.id)
      assert client_service.uid == found.uid
      assert client_service.url == found.url
    end

    test "create_client_service/1 with valid data creates a client_service" do
      administrator = insert(:administrator)

      assert {:ok, %ClientService{} = client_service} =
               ClientServices.create_client_service(@valid_attrs, administrator)

      assert client_service.description == @valid_attrs[:description]
      assert client_service.name == @valid_attrs[:name]
      assert client_service.redirect_url == @valid_attrs[:redirect_url]
      assert client_service.url == @valid_attrs[:url]
      assert client_service.logo == @valid_attrs[:logo]

      assert client_service.email_confirmation_redirect_url ==
               @valid_attrs[:email_confirmation_redirect_url]

      assert client_service.pass_change_redirect_url == @valid_attrs[:pass_change_redirect_url]
    end

    test "create_client_service/1 creates two ApiKey's" do
      administrator = insert(:administrator)
      before_create = ClientServices.list_api_keys() |> length()

      assert {:ok, %ClientService{} = client_service} =
               ClientServices.create_client_service(@valid_attrs, administrator)

      api_keys = ClientServices.list_api_keys()
      assert length(api_keys) == before_create + 2

      pub_key =
        Enum.find(api_keys, fn key ->
          key.type == "public" && key.client_service_id == client_service.id
        end)

      assert pub_key.data != nil

      prv_key =
        Enum.find(api_keys, fn key ->
          key.type == "private" && key.client_service_id == client_service.id
        end)

      assert prv_key.data != nil
    end

    test "create_client_service/1 with invalid data returns error changeset" do
      administrator = insert(:administrator)

      assert {:error, %Ecto.Changeset{}} =
               ClientServices.create_client_service(@invalid_attrs, administrator)
    end

    test "update_client_service/2 with valid data updates the client_service" do
      client_service = insert(:client_service)

      assert {:ok, %ClientService{} = client_service} =
               ClientServices.update_client_service(client_service, @update_attrs)

      assert client_service.description == "some updated description"
      assert client_service.name == "some updated name"
      assert client_service.redirect_url == "some updated redirect_url"
      assert client_service.url == "some updated url"
      assert client_service.logo == "some updated logo"
      assert client_service.email_confirmation_redirect_url == "some updated confirmation url"

      assert client_service.pass_change_redirect_url ==
               "some updated password change redirect url"
    end

    test "update_client_service/2 with invalid data returns error changeset" do
      client_service = ClientServices.get_client_service!(insert(:client_service).id)

      assert {:error, %Ecto.Changeset{}} =
               ClientServices.update_client_service(client_service, @invalid_attrs)

      assert client_service == ClientServices.get_client_service!(client_service.id)
    end

    test "add_administrator/2" do
      administrator = insert(:administrator)
      client_service = insert(:client_service)

      {:ok, %ClientService{}} = ClientServices.add_administrator(client_service, administrator)

      administrator =
        Administration.get_administrator!(administrator.id) |> Repo.preload(:client_services)

      assert administrator.client_services == [client_service]
    end

    test "remove_administrator/2" do
      client_service = insert(:client_service)
      administrator_1 = insert(:administrator)
      administrator_2 = insert(:administrator)

      {:ok, %ClientService{}} = ClientServices.add_administrator(client_service, administrator_1)
      {:ok, %ClientService{}} = ClientServices.add_administrator(client_service, administrator_2)

      client_service =
        ClientServices.get_client_service!(client_service.id) |> Repo.preload(:administrators)

      assert length(client_service.administrators) == 2

      {:ok, %ClientService{}} =
        ClientServices.remove_administrator(client_service, administrator_1)

      client_service =
        ClientServices.get_client_service!(client_service.id) |> Repo.preload(:administrators)

      [administrator] = client_service.administrators
      assert administrator.id == administrator_2.id

      not_deleted = Administration.get_administrator!(administrator_1.id)
      assert not_deleted.deleted_at == nil
    end

    test "delete_client_service/1 deletes the client_service and the api keys" do
      administrator = insert(:administrator)

      assert {:ok, %ClientService{id: id}} =
               ClientServices.create_client_service(@valid_attrs, administrator)

      client_service = ClientServices.get_client_service!(id)
      api_keys = client_service.api_keys
      assert 2 == length(api_keys)

      assert {:ok, %{client_service: %ClientService{}}} =
               ClientServices.delete_client_service(client_service)

      assert_raise Ecto.NoResultsError, fn ->
        ClientServices.get_client_service!(client_service.id)
      end

      soft_deleted = Repo.get!(ClientService, client_service.id)
      assert client_service.id == soft_deleted.id
      refute soft_deleted.deleted_at == nil

      for api_key <- api_keys do
        assert nil == ClientServices.get_api_key_by_data(api_key.data)

        assert_raise Ecto.NoResultsError, fn ->
          ClientServices.get_api_key!(api_key.id)
        end
      end
    end

    test "change_client_service/1 returns a update_client_service changeset" do
      client_service = insert(:client_service)
      assert %Ecto.Changeset{} = ClientServices.change_client_service(client_service)
    end

    test "new_client_service/1 returns a new_client_service changeset" do
      administrator = insert(:administrator)

      assert %Ecto.Changeset{} =
               ClientServices.new_client_service(%ClientService{}, %{}, administrator)
    end
  end

  describe "api_keys" do
    test "list_api_keys/0 returns all api_keys" do
      insert(:api_key)
      assert ClientServices.list_api_keys() != []
    end

    test "get_api_key!/1 returns the api_key with given id" do
      api_key = insert(:api_key)
      found = ClientServices.get_api_key!(api_key.id)
      assert found.data == api_key.data
      assert found.uid == api_key.uid
    end

    test "create_api_key/1 with valid data creates a api_key" do
      client_service = insert(:client_service)

      assert {:ok, %ApiKey{} = api_key} =
               ClientServices.create_api_key(%{
                 client_service_id: client_service.id,
                 type: "public"
               })

      assert api_key.data != nil
      assert String.length(api_key.data) == 47
      assert api_key.type == "public"
      assert api_key.uid != nil
    end

    test "create_api_key/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               ClientServices.create_api_key(%{client_service_id: nil})
    end

    test "roll_api_keys/1 soft delets the current keys and creates new keys" do
      client_service = insert(:client_service)

      assert {:ok, %ApiKey{} = public_api_key} =
               ClientServices.create_api_key(%{
                 client_service_id: client_service.id,
                 type: "public"
               })

      assert {:ok, %ApiKey{} = private_api_key} =
               ClientServices.create_api_key(%{
                 client_service_id: client_service.id,
                 type: "public"
               })

      client_service = ClientServices.get_client_service!(client_service.id)
      assert 2 == length(client_service.api_keys)
      assert {:ok, _} = ClientServices.roll_api_keys(client_service)

      rolled_client_service = ClientServices.get_client_service!(client_service.id)
      assert 2 == length(client_service.api_keys)
      assert Enum.all?(rolled_client_service.api_keys, fn key -> key.deleted_at == nil end)

      public_api_key = Repo.get(ApiKey, public_api_key.id)
      assert public_api_key.deleted_at != nil

      private_api_key = Repo.get(ApiKey, private_api_key.id)
      assert private_api_key.deleted_at != nil
    end

    test "delete_api_key/1 soft deletes the api_key" do
      api_key = insert(:api_key)
      assert {:ok, %ApiKey{}} = ClientServices.delete_api_key(api_key)
      assert_raise Ecto.NoResultsError, fn -> ClientServices.get_api_key!(api_key.id) end
      soft_deleted = Repo.get!(ApiKey, api_key.id)
      assert api_key.id == soft_deleted.id
      refute soft_deleted.deleted_at == nil
    end
  end

  describe "state_secrets" do
    test "create_state_secret!/1 " do
      client_service = insert(:client_service)
      state_secret = ClientServices.create_state_secret!(client_service)

      assert String.length(state_secret.secret) == 48
      assert state_secret.owner == client_service
      assert state_secret.created_at != nil
    end

    test "create_state_secret!/1 wihout a clear_service returns error" do
      assert {:error, :invalid_client_service} ==
               ClientServices.create_state_secret!("not cool dude")
    end
  end

  describe "withdraw_state_secret!/1" do
    test "deletes and returns the state_secret" do
      client_service = insert(:client_service)
      state_secret = ClientServices.create_state_secret!(client_service)

      assert state_secret == ClientServices.withdraw_state_secret(state_secret.secret)

      assert {:error, "Elixir.HubIdentity.ClientServices.StateSecret not found"} ==
               ClientServices.withdraw_state_secret(state_secret.secret)
    end
  end
end
