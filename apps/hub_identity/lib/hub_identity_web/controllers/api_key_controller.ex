defmodule HubIdentityWeb.ApiKeyController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.ClientServices

  def create(conn, %{"api_key" => api_key_params}) do
    case ClientServices.create_api_key(api_key_params) do
      {:ok, api_key} ->
        conn
        |> put_flash(:info, "Api key created successfully.")
        |> redirect(to: Routes.api_key_path(conn, :show, api_key))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    api_key = ClientServices.get_api_key!(id)
    render(conn, "show.html", api_key: api_key)
  end

  def delete(conn, %{"id" => id}) do
    api_key = ClientServices.get_api_key!(id)
    {:ok, _api_key} = ClientServices.delete_api_key(api_key)

    conn
    |> put_flash(:info, "Api key deleted successfully.")
    |> redirect(to: Routes.api_key_path(conn, :index))
  end
end
