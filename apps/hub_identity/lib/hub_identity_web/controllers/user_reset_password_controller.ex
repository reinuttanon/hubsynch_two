defmodule HubIdentityWeb.UserResetPasswordController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities

  def edit(conn, %{"token" => token}) do
    with {:ok, client_service, user} <- Identities.get_user_by_reset_password_token(token) do
      conn
      |> assign(:user, user)
      |> assign(:token, token)
      |> assign(:client_service, client_service)
      |> render("edit.html", changeset: Identities.change_user_password(user))
    else
      _ -> fail_response(conn)
    end
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"token" => token, "user" => user_params}) do
    with {:ok, client_service, user} <- Identities.get_user_by_reset_password_token(token),
         {:ok, _} <- Identities.reset_user_password(user, user_params) do
      conn
      |> response(client_service)
    else
      {:error, changeset} ->
        conn
        |> assign(:token, token)
        |> render("edit.html", changeset: changeset)

      _ ->
        fail_response(conn)
    end
  end

  defp fail_response(conn) do
    conn
    |> put_flash(:error, "Reset password link is invalid or it has expired.")
    |> redirect(to: Routes.public_users_path(conn, :complete))
    |> halt()
  end

  defp response(conn, %ClientService{pass_change_redirect_url: pass_change_redirect_url})
       when is_binary(pass_change_redirect_url) and pass_change_redirect_url != "" do
    redirect(conn, external: pass_change_redirect_url)
  end

  defp response(conn, _) do
    conn
    |> put_flash(:info, "Password reset successfully.")
    |> redirect(to: Routes.public_users_path(conn, :complete))
  end
end
