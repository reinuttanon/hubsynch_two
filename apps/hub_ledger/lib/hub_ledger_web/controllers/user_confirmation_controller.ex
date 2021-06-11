defmodule HubLedgerWeb.UserConfirmationController do
  use HubLedgerWeb, :controller

  alias HubLedger.Users

  def confirm(conn, %{"access_request" => access_request_id}) do
    with user_id when is_integer(user_id) <- get_session(conn, :user_id),
         {:ok, %{to: user_email}} <-
           Users.deliver_access_notification(
             access_request_id,
             user_id,
             Routes.session_url(conn, :new)
           ) do
      conn
      |> put_flash(:info, "#{user_email} user account successfully confirmed")
      |> redirect(to: "/ledger_dashboard")
    end
  end
end
