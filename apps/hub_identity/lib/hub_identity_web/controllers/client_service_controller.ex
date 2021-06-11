defmodule HubIdentityWeb.ClientServiceController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.Administration
  alias HubIdentity.Administration.Administrator
  alias HubIdentity.ClientServices
  alias HubIdentity.ClientServices.ClientService

  def index(conn, _params) do
    administrator = conn.assigns[:current_administrator]

    client_services =
      case administrator.system do
        true -> ClientServices.list_client_services()
        false -> ClientServices.list_client_services(%{administrator_id: administrator.id})
      end

    render(conn, "index.html", client_services: client_services)
  end

  def new(conn, _params) do
    administrator = conn.assigns[:current_administrator]
    changeset = ClientServices.new_client_service(%ClientService{}, %{}, administrator)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client_service" => client_service_params}) do
    administrator = conn.assigns[:current_administrator]

    case ClientServices.create_client_service(client_service_params, administrator) do
      {:ok, client_service} ->
        conn
        |> put_flash(:info, "Client service created successfully.")
        |> redirect(to: Routes.client_service_path(conn, :show, client_service))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    client_service = ClientServices.get_client_service!(id)
    render(conn, "show.html", client_service: client_service)
  end

  def edit(conn, %{"id" => id}) do
    client_service = ClientServices.get_client_service!(id)
    changeset = ClientServices.change_client_service(client_service)
    render(conn, "edit.html", client_service: client_service, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client_service" => client_service_params}) do
    client_service = ClientServices.get_client_service!(id)

    case ClientServices.update_client_service(client_service, client_service_params) do
      {:ok, client_service} ->
        conn
        |> put_flash(:info, "Client service updated successfully.")
        |> redirect(to: Routes.client_service_path(conn, :show, client_service))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", client_service: client_service, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    client_service = ClientServices.get_client_service!(id)
    {:ok, _client_service} = ClientServices.delete_client_service(client_service)

    conn
    |> put_flash(:info, "Client service deleted successfully.")
    |> redirect(to: Routes.client_service_path(conn, :index))
  end

  def roll_api_keys(conn, %{"id" => id}) do
    with %ClientService{} = client_service <- ClientServices.get_client_service!(id),
         {:ok, _} <- ClientServices.roll_api_keys(client_service) do
      conn
      |> put_flash(:info, "API keys successfully rolled.")
      |> redirect(to: Routes.client_service_path(conn, :show, client_service))
    end
  end

  # POST
  def add_administrator(%Plug.Conn{method: "POST"} = conn, %{
        "id" => id,
        "administrator_id" => administrator_id
      }) do
    with %ClientService{} = client_service <- ClientServices.get_client_service!(id),
         %Administrator{} = administrator <- Administration.get_administrator!(administrator_id),
         {:ok, %ClientService{}} <-
           ClientServices.add_administrator(client_service, administrator) do
      conn
      |> put_flash(:info, "Administrator added successfully.")
      |> redirect(to: Routes.client_service_path(conn, :show, client_service))
    end
  end

  # GET
  def add_administrator(conn, %{"id" => id}) do
    with %ClientService{administrators: current_administrators} = client_service <-
           ClientServices.get_client_service!(id),
         all_administrators when is_list(all_administrators) <-
           Administration.list_client_services_administrators(),
         administrators <- unique_administrators(all_administrators, current_administrators) do
      render(conn, "add_administrator.html",
        administrators: administrators,
        client_service: client_service
      )
    end
  end

  # POST
  def remove_administrator(conn, %{
        "id" => id,
        "administrator_id" => administrator_id
      }) do
    with %ClientService{} = client_service <- ClientServices.get_client_service!(id),
         %Administrator{} = administrator <- Administration.get_administrator!(administrator_id),
         {:ok, %ClientService{}} <-
           ClientServices.remove_administrator(client_service, administrator) do
      conn
      |> put_flash(:info, "Administrator removed successfully.")
      |> redirect(to: Routes.client_service_path(conn, :show, client_service))
    end
  end

  defp unique_administrators(all_administrators, current_administrators) do
    all_administrators -- current_administrators
  end
end
