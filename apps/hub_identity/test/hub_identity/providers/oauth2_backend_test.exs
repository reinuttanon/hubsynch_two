defmodule HubIdentity.HubsynchV2.Oauth2BackendTest do
  use HubIdentity.DataCase

  alias HubIdentity.Providers
  alias HubIdentity.Providers.Oauth2Backend

  describe "get_tokens/1" do
    test "with google returns the access_token" do
      google_url =
        "www.google.com?client_id=client_id_123&client_secret=client_secret_shhhhhh!&grant_type=authorization_code&redirect_uri=http://test.com/api/v1/providers/oauth/response/google&code=1234"

      HubIdentity.Factory.params_for(:provider_config, %{
        name: "google",
        access_token_url: google_url
      })
      |> Providers.create_provider_config()

      provider = Providers.get_provider_by_name("google")

      {:ok, %{"access_token" => access_token}} = Oauth2Backend.get_tokens(provider)
      assert access_token != nil
    end

    test "with facebook returns the access_token" do
      facebook_url =
        "www.facebook.com?client_id=client_id_123&client_secret=client_secret_shhhhhh!&grant_type=authorization_code&redirect_uri=http://test.com/api/v1/providers/oauth/response/facebook&code=1234"

      HubIdentity.Factory.params_for(:provider_config, %{
        name: "facebook",
        access_token_url: facebook_url
      })
      |> Providers.create_provider_config()

      provider = Providers.get_provider_by_name("facebook")

      {:ok, %{"access_token" => access_token}} = Oauth2Backend.get_tokens(provider)
      assert access_token != nil
    end
  end
end
