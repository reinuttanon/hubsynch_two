defmodule HubIdentityWeb.Api.V1.ProviderView do
  @moduledoc false
  use HubIdentityWeb, :view

  alias HubIdentityWeb.Api.V1.ProviderView

  def render("index.json", %{providers: providers}) do
    render_many(providers, ProviderView, "provider.json")
  end

  def render("provider.json", %{provider: provider}) do
    %{
      name: provider.name,
      logo_url: provider.logo_url,
      request_url: provider.request_url
    }
  end

  def render("show.json", %{access_token: access_token, refresh_token: refresh_token}) do
    %{
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def render("show.json", %{access_token: access_token, claims: claims}) do
    %{
      access_token: access_token,
      expires: claims["exp"],
      scope: "hub_identity offline_access",
      token_type: "Bearer"
    }
  end

  def render("show.json", %{response: response}) do
    response
  end
end
