defmodule HubLedgerWeb.Authentication.UserAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias HubLedger.Users
  alias HubLedger.Users.User
  def init(opts), do: opts

  def log_in_user(conn, user) do
    administrator_return_to = get_session(conn, :administrator_return_to)

    conn
    |> fetch_session()
    |> renew_session()
    |> put_session(:user_id, user.id)
    |> put_flash(:info, "You Have Successfully Logged")
    |> redirect(to: administrator_return_to || signed_in_path(conn))
  end

  def log_out_user(conn) do
    conn
    |> renew_session()
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end

  def call(conn, _opt) do
    with user_id when is_integer(user_id) <- get_session(conn, :user_id),
         %User{} = user <- Users.get_user!(user_id) do
      conn
      |> assign(:current_user, user)
    else
      _ ->
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> maybe_store_return_to()
        |> redirect(to: "/")
        |> halt()
    end
  end

  @doc """
  Used for routes that require the administrator to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    with user_id when is_integer(user_id) <- get_session(conn, :user_id),
         %User{} <- Users.get_user!(user_id) do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      _ -> conn
    end
  end

  def fetch_current_ledger_user(conn, _opts) do
    assign(conn, :current_user, get_session(conn, :user_id))
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :administrator_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp signed_in_path(_conn), do: "/ledger_dashboard"
end
