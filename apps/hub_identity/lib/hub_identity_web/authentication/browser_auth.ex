defmodule HubIdentityWeb.Authentication.BrowserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias HubIdentity.{ClientServices, Metrics}
  alias HubIdentity.ClientServices.{ApiKey, ClientService}
  alias HubIdentityWeb.Authentication.AccessCookie
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  def init(opts), do: opts

  @doc """
  Look for cookies that exist and are valid, then redirect back to the client_service.
  """
  def call(
        %Plug.Conn{
          req_cookies: %{"_hub_identity_access" => cookie_id},
          query_params: %{"api_key" => api_key}
        } = conn,
        _opts
      ) do
    with %ApiKey{
           client_service: %ClientService{redirect_url: redirect_url, uid: client_service_uid}
         } <-
           ClientServices.get_api_key_by_data(api_key),
         %AccessCookie{owner: owner} <- AccessCookiesServer.get_cookie(cookie_id) do
      conn
      |> Metrics.cookie_activity(owner, client_service_uid, "AccessCookie.redirect")
      |> redirect(external: "#{redirect_url}?user_token=#{cookie_id}")
      |> halt()
    else
      _ -> conn
    end
  end

  def call(conn, _opts), do: conn
end
