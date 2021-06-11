defmodule HubIdentityWeb.Api.V1.CurrentUserController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  alias HubIdentityWeb.Authentication.AccessCookie
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  # Private key actions
  def show(conn, %{"cookie_id" => cookie_id}) do
    with %AccessCookie{owner: user} <- AccessCookiesServer.get_cookie(cookie_id) do
      render(conn, "show.json", %{user: user})
    end
  end
end
