defmodule HubIdentityWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use Phoenix.Controller, namespace: HubIdentityWeb

  import Plug.Conn

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(HubIdentityWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(:not_found)
    |> put_view(HubIdentityWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, _) do
    conn
    |> put_status(:not_found)
    |> put_view(HubIdentityWeb.ErrorView)
    |> render(:"404")
  end
end
