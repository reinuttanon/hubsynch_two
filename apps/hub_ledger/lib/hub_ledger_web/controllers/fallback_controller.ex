defmodule HubLedgerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Phoenix.Controller, namespace: HubLedgerWeb

  import Plug.Conn

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(HubLedgerWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, message}) do
    conn
    |> put_flash(:error, message)
    |> redirect(to: "/ledger_dashboard")
  end

  def call(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(HubLedgerWeb.ErrorView)
    |> render(:"404")
  end
end
