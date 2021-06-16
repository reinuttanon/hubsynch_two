defmodule HubLedgerWeb.SessionController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Users
  alias HubLedgerWeb.Authentication.UserAuth

  @hub_identity Application.get_env(:hub_ledger, :hub_identity)

  def new(conn, _) do
    with {:ok, providers} <- @hub_identity.get_providers(),
         {:ok, request_url} <- get_google(providers) do
      redirect(conn, external: request_url)
    end
  end

  def create(conn, %{"user_token" => user_token}) do
    with {:ok, user} <- Users.get_user(%{user_token: user_token}) do
      UserAuth.log_in_user(conn, user)
    else
      {:error, user_email, hub_identity_uid} ->
        conn
        |> generate_acccess_request(user_email, hub_identity_uid)
        |> put_flash(:info, "Access Request Sent to the Administrator")
        |> redirect(to: "/")

      {:error, message} ->
        {:error, message}
    end
  end

  def generate_acccess_request(conn, user_email, hub_identity_uid) do
    Users.create_access_request_and_notify(user_email, hub_identity_uid, fn access_request_id ->
      Routes.user_confirmation_url(conn, :confirm, %{"access_request" => access_request_id})
    end)

    conn
  end

  def log_out(conn, _params) do
    UserAuth.log_out_user(conn)
  end

  defp get_google([]), do: {:errors, "no google url"}

  defp get_google([%{"name" => "google", "request_url" => request_url} | _tail]),
    do: {:ok, request_url}

  defp get_google([_head | tail]), do: get_google(tail)
end
