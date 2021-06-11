defmodule HubIdentityWeb.UserConfirmationController do
  @moduledoc false

  use HubIdentityWeb, :controller

  import HubIdentityWeb.AuthenticationResponseHelper, only: [respond: 4]

  alias HubIdentity.{Identities, Metrics, Verifications}
  alias HubIdentity.Verifications.EmailVerifyReference

  def confirm(conn, %{"token" => reference}) do
    with {:ok,
          %EmailVerifyReference{
            client_service_uid: client_service_uid,
            redirect_url: redirect_url
          } = email_verify_reference} <-
           Verifications.withdraw_verify_email_reference(reference),
         {:ok, create_map} <- Identities.handle_confirmation(email_verify_reference) do
      response(conn, redirect_url, create_map, client_service_uid)
    end
  end

  defp response(conn, redirect_url, create_map, client_service_uid)
       when is_binary(redirect_url) and redirect_url != "" do
    respond(conn, create_map, redirect_url, client_service_uid)
  end

  defp response(conn, _, create_map, client_service_uid) do
    conn
    |> Metrics.create_activities(create_map, client_service_uid)
    |> put_flash(:info, "Account confirmed successfully")
    |> redirect(to: Routes.public_users_path(conn, :complete))
    |> halt()
  end
end
