defmodule HubIdentity.ProvidersTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Providers
  alias HubIdentity.Providers.{Oauth2Provider, ProviderConfig}
  alias HubIdentity.ClientServices.StateSecret

  describe "providers" do
    @valid_attrs params_for(:provider_config)
    @update_attrs %{
      access_token_url: "www.updated.com/token/url",
      auth_url: "some updated auth_url",
      client_id: "some updated client_id",
      client_secret: "some updated client_secret",
      name: "some updated name",
      scopes: ""
    }
    @invalid_attrs %{
      auth_url: nil,
      client_id: nil,
      client_secret: nil,
      name: nil
    }

    test "list_provider_configs/0 returns all providers" do
      provider_config = insert(:provider_config)
      assert Providers.list_provider_configs() == [provider_config]
    end

    test "get_provider_config!/1 returns the provider with given id" do
      provider_config = insert(:provider_config)
      assert Providers.get_provider_config!(provider_config.id) == provider_config
    end

    test "create_provider/1 with valid data creates a provider" do
      assert {:ok, %ProviderConfig{} = provider_config} =
               Providers.create_provider_config(@valid_attrs)

      assert provider_config.auth_url == "http://www.auth_url"
      assert provider_config.client_id == "client_id_123"
      assert provider_config.client_secret == "client_secret_shhhhhh!"
      assert provider_config.name =~ "twinner"
      assert provider_config.scopes == "see_everything.api, doo_everything.api"
      assert provider_config.uid != nil
    end

    test "create_provider/1 with valid data updates the oauth_providers" do
      assert {:error, :provider_not_found} == Providers.get_provider_by_name("ErinOauth")
      valid_attrs = params_for(:provider_config, %{name: "ErinOauth"})

      assert {:ok, %ProviderConfig{} = provider_config} =
               Providers.create_provider_config(valid_attrs)

      assert provider = Providers.get_provider_by_name("erinoauth")
      assert provider.name == provider_config.name
      assert provider.request_url =~ provider_config.auth_url
      assert provider.token_url =~ provider_config.access_token_url
    end

    test "create_provider/1 with active false does not create a oauth_provider" do
      valid_attrs = params_for(:provider_config, %{active: false})

      assert {:ok, %ProviderConfig{} = provider_config} =
               Providers.create_provider_config(valid_attrs)

      assert {:error, :provider_not_found} == Providers.get_provider_by_name(provider_config.name)
    end

    test "create_provider_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Providers.create_provider_config(@invalid_attrs)
    end

    test "update_provider_config/2 with valid data updates the provider" do
      provider_config = insert(:provider_config)

      assert {:ok, %ProviderConfig{} = updated_provider_config} =
               Providers.update_provider_config(provider_config, @update_attrs)

      assert updated_provider_config.auth_url == "some updated auth_url"
      assert updated_provider_config.client_id == "some updated client_id"
      assert updated_provider_config.client_secret == "some updated client_secret"
      assert updated_provider_config.name == "some_updated_name"
      assert updated_provider_config.scopes == nil
    end

    test "update_provider_config/2 updates the oauth_providers" do
      valid_attrs = params_for(:provider_config, %{name: "ErinOauth"})

      {:ok, provider_config} = Providers.create_provider_config(valid_attrs)

      assert %Oauth2Provider{} = Providers.get_provider_by_name(provider_config.name)

      assert {:ok, %ProviderConfig{} = updated_provider_config} =
               Providers.update_provider_config(provider_config, @update_attrs)

      assert provider = Providers.get_provider_by_name(updated_provider_config.name)

      assert provider.name == "some_updated_name"
      assert provider.request_url =~ "some updated auth_url"
      assert provider.token_url =~ "www.updated.com/token/url"

      # Ensure the old provider_config is gone
      assert {:error, :provider_not_found} = Providers.get_provider_by_name(provider_config.name)
    end

    test "update_provider_config/2 removes the oauth_provider if active is changed to false" do
      valid_attrs = params_for(:provider_config, %{name: "ErinOauth"})

      {:ok, provider_config} = Providers.create_provider_config(valid_attrs)

      assert %Oauth2Provider{} = Providers.get_provider_by_name(provider_config.name)

      assert {:ok, %ProviderConfig{}} =
               Providers.update_provider_config(provider_config, %{active: false})

      assert {:error, :provider_not_found} = Providers.get_provider_by_name(provider_config.name)
    end

    test "update_provider_config/2 with invalid data returns error changeset" do
      provider_config = insert(:provider_config)

      assert {:error, %Ecto.Changeset{}} =
               Providers.update_provider_config(provider_config, @invalid_attrs)

      assert provider_config == Providers.get_provider_config!(provider_config.id)
    end

    test "delete_provider_config/1 deletes the provider_config" do
      provider_config = insert(:provider_config)
      assert {:ok, %ProviderConfig{}} = Providers.delete_provider_config(provider_config)

      assert_raise Ecto.NoResultsError, fn ->
        Providers.get_provider_config!(provider_config.id)
      end
    end

    test "change_provider_config/1 returns a provider_config changeset" do
      provider_config = insert(:provider_config)
      assert %Ecto.Changeset{} = Providers.change_provider_config(provider_config)
    end

    test "parse_delete_request/2 returns the result of the request parse" do
      request = facebook_request()

      provider_config =
        insert(:provider_config, name: "facebook", client_secret: "client_secret_shhhhhh!")

      assert {:ok, "218471"} =
               Providers.parse_delete_request(provider_config, %{"signed_request" => request})
    end

    test "get_provider_config_by_name/1 returns the provider config" do
      provider_config = insert(:provider_config, name: "faceboots")

      assert provider_config == Providers.get_provider_config_by_name("faceboots")
    end

    test "get_provider_config_by_name/1 returns nil if invalid name" do
      assert nil == Providers.get_provider_config_by_name("faceboots")
    end

    test "parse_delete_request/2 returns the errors from the request parse" do
      provider_config = insert(:provider_config, name: "facebook")

      request = "eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4"

      assert {:error, :data_deletion_failure} =
               Providers.parse_delete_request(provider_config, %{"signed_request" => request})
    end
  end

  describe "oauth_providers" do
    test "list_oauth_providers/1 returns all Oauth providers" do
      for _ <- 1..3 do
        insert(:provider_config) |> Providers.create_oauth2_provider()
      end

      state_secret = StateSecret.create_changeset("Erin")
      oauth_providers = Providers.list_oauth_providers(state_secret)
      assert length(oauth_providers) >= 3
    end

    test "get_provider_by_name/1 returns the provider" do
      {:ok, provider} = insert(:provider_config) |> Providers.create_oauth2_provider()
      assert found_provider = Providers.get_provider_by_name(provider.name)
      assert found_provider.name == provider.name
      assert found_provider.request_url == provider.request_url
      assert found_provider.token_url == provider.token_url
    end

    test "get_provider_by_name/1 returns error tuple if no provider" do
      assert {:error, :provider_not_found} == Providers.get_provider_by_name("nopesies")
    end

    test "create_oauth2_provider/1 returns an Oauth2Provider" do
      provider_config = insert(:provider_config)
      assert {:ok, provider} = Providers.create_oauth2_provider(provider_config)
      assert provider.name == provider_config.name
      assert provider.request_url =~ provider_config.auth_url
      assert provider.token_url =~ provider_config.access_token_url
    end

    test "create_oauth2_provider/1 does not allow duplicate named providers" do
      provider_config = insert(:provider_config)
      Providers.create_oauth2_provider(provider_config)
      pre = HubIdentity.MementoRepo.all(HubIdentity.Providers.Oauth2Provider) |> length()
      Providers.create_oauth2_provider(provider_config)
      Providers.create_oauth2_provider(provider_config)
      Providers.create_oauth2_provider(provider_config)
      post = HubIdentity.MementoRepo.all(HubIdentity.Providers.Oauth2Provider) |> length()
      assert pre == post
    end
  end

  defp facebook_request do
    # The following was reversed engineered from the Facebook docuemenation using the secret: "client_secret_shhhhhh!"
    # the data is:
    # %{
    #    algorithm: "HMAC-SHA256",
    #    expires: 1291840400,
    #    issued_at: 1291836800,
    #    user_id: "218471"
    # }
    "w5ZbbWP9yOwBA1uJZbc7-9gZok0O42U4i0yyvxXE_jY.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEyOTE4NDA0MDAsImlzc3VlZF9hdCI6MTI5MTgzNjgwMCwidXNlcl9pZCI6IjIxODQ3MSJ9"
  end
end
