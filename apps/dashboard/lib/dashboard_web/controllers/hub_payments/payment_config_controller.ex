defmodule DashboardWeb.HubPayments.PaymentConfigController do
  use DashboardWeb, :controller

  alias HubIdentity.ClientServices, as: IdentityClients
  alias HubPayments.ClientServices, as: PaymentsClients

  def index(conn, _params) do
    payment_configs = PaymentsClients.list_payment_configs()
    render(conn, "index.html", %{payment_configs: payment_configs})
  end

  def new(conn, _params) do
    # changeset = ClientServices.new_client_service(%ClientService{}, %{}, administrator)
    # render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client_service" => client_service_params}) do
    # administrator = conn.assigns[:current_administrator]

    # case ClientServices.create_client_service(client_service_params, administrator) do
    #   {:ok, client_service} ->
    #     conn
    #     |> put_flash(:info, "Client service created successfully.")
    #     |> redirect(to: Routes.client_service_path(conn, :show, client_service))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "new.html", changeset: changeset)
    # end
  end

  def show(conn, %{"id" => id}) do
    # client_service = ClientServices.get_client_service!(id)
    # render(conn, "show.html", client_service: client_service)
  end

  def edit(conn, %{"id" => id}) do
    # client_service = ClientServices.get_client_service!(id)
    # changeset = ClientServices.change_client_service(client_service)
    # render(conn, "edit.html", client_service: client_service, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client_service" => client_service_params}) do
    # client_service = ClientServices.get_client_service!(id)

    # case ClientServices.update_client_service(client_service, client_service_params) do
    #   {:ok, client_service} ->
    #     conn
    #     |> put_flash(:info, "Client service updated successfully.")
    #     |> redirect(to: Routes.client_service_path(conn, :show, client_service))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", client_service: client_service, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    #   client_service = ClientServices.get_client_service!(id)
    #   {:ok, _client_service} = ClientServices.delete_client_service(client_service)

    #   conn
    #   |> put_flash(:info, "Client service deleted successfully.")
    #   |> redirect(to: Routes.client_service_path(conn, :index))
  end
end
