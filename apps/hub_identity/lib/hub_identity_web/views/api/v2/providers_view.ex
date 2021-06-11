defmodule HubIdentityWeb.Api.V2.ProvidersView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("show.json", %{access_token: access_token, refresh_token: refresh_token}) do
    %{
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def render("show.json", %{response: response}) do
    response
  end
end
