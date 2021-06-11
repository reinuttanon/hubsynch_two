defmodule HubIdentity.HubsynchV2.ProviderTest do
  use HubIdentity.DataCase

  import HubIdentity.Factory

  alias HubIdentity.Providers.ProviderConfig

  describe "build_request_url/1" do
    setup [:create_provider_config]

    test "returns a full url with all fields", %{provider_config: provider_config} do
      url = ProviderConfig.build_request_url(provider_config)
      assert url =~ "www.auth_url"
      assert url =~ "?client_id=client_id_123"
      assert url =~ "&redirect_uri=http://test.com/api/v1/providers/oauth/response"
      assert url =~ "&scope=see_everything.api, doo_everything.api"
    end

    test "returns url without scopes" do
      provider_config = insert(:provider_config, %{scopes: ""})
      url = ProviderConfig.build_request_url(provider_config)
      assert url =~ "www.auth_url"
      assert url =~ "?client_id=client_id_123"
      assert url =~ "&redirect_uri=http://test.com/api/v1/providers/oauth/response"
      refute url =~ "scope"
      refute url =~ "state"
    end
  end

  describe "build_token_url/1" do
    setup [:create_provider_config]

    test "returns a full url with all the fields", %{provider_config: provider_config} do
      url = ProviderConfig.build_token_url(provider_config)
      assert url =~ "www.access_token.url"
      assert url =~ "?client_id=client_id_123"
      assert url =~ "&client_secret=client_secret_shhhhhh!"
      assert url =~ "&redirect_uri=http://test.com/api/v1/providers/oauth/response"
      assert url =~ "&grant_type=authorization_code"
    end
  end

  defp create_provider_config(_) do
    provider_config = insert(:provider_config)
    %{provider_config: provider_config}
  end
end
