defmodule HubIdentityWeb.AuthenticationResponseHelper do
  @moduledoc false
  use HubIdentityWeb, :controller

  alias HubIdentity.Metrics
  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities.User
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  @cookie_name HubIdentityWeb.Authentication.AccessCookie.cookie_name()
  @max_age HubIdentityWeb.Authentication.AccessCookie.max_age()

  def respond(
        conn,
        create_map,
        %ClientService{redirect_url: redirect_url, uid: client_service_uid},
        provider
      ) do
    conn
    |> Metrics.create_activities(create_map, client_service_uid, provider)
    |> send_cookie_response(create_map, redirect_url, client_service_uid, provider)
  end

  def respond(
        conn,
        %User{} = user,
        %ClientService{redirect_url: redirect_url, uid: client_service_uid},
        provider
      ) do
    send_cookie_response(conn, user, redirect_url, client_service_uid, provider)
  end

  def respond(conn, create_map, redirect_url, client_service_uid) do
    conn
    |> Metrics.create_activities(create_map, client_service_uid)
    |> send_cookie_response(create_map, redirect_url, client_service_uid)
  end

  defp send_cookie_response(
         conn,
         create_map,
         redirect_url,
         client_service_uid,
         provider \\ "HubIdentity"
       ) do
    with {:ok, cookie} <- AccessCookiesServer.create_cookie(create_map, provider) do
      conn
      |> Metrics.cookie_activity(cookie, client_service_uid)
      |> put_resp_cookie(@cookie_name, cookie.id, max_age: @max_age)
      |> redirect(external: "#{redirect_url}?user_token=#{cookie.id}")
      |> halt()
    end
  end
end
