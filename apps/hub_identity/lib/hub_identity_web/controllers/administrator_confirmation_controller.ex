defmodule HubIdentityWeb.AdministratorConfirmationController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.Administration

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"administrator" => %{"email" => address}}) do
    if administrator = Administration.get_administrator_by_email(address) do
      Administration.deliver_administrator_confirmation_instructions(
        administrator,
        &Routes.administrator_confirmation_url(conn, :confirm, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  # Do not log in the administrator after confirmation to avoid a
  # leaked token giving the administrator access to the account.
  def confirm(conn, %{"token" => token}) do
    case Administration.confirm_administrator(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current administrator and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the administrator themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_administrator: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
