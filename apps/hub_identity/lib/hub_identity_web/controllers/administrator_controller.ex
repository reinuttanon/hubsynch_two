defmodule HubIdentityWeb.AdministratorController do
  @moduledoc false

  use HubIdentityWeb, :controller

  alias HubIdentity.Administration
  alias HubIdentity.Administration.Administrator

  def index(conn, _params) do
    administrators = Administration.list_administrators()
    render(conn, "index.html", administrators: administrators)
  end

  def new(conn, _params) do
    changeset = Administration.change_administrator(%Administrator{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"administrator" => administrator_params}) do
    case Administration.create_administrator(administrator_params) do
      {:ok, administrator} ->
        Administration.deliver_administrator_reset_password_instructions(
          administrator,
          &Routes.administrator_reset_password_url(conn, :edit, &1)
        )

        conn
        |> put_flash(:info, "Administrator created successfully.")
        |> redirect(to: Routes.administrator_path(conn, :show, administrator))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    administrator = Administration.get_administrator!(id)
    render(conn, "show.html", administrator: administrator)
  end

  def edit(conn, %{"id" => id}) do
    administrator = Administration.get_administrator!(id)
    changeset = Administration.change_administrator(administrator)
    render(conn, "edit.html", administrator: administrator, changeset: changeset)
  end

  # def update(conn, %{"id" => id, "administrator" => administrator_params}) do
  #   administrator = Administration.get_administrator!(id)
  #
  #   case Administration.update_administrator(administrator, administrator_params) do
  #     {:ok, administrator} ->
  #       conn
  #       |> put_flash(:info, "Administrator updated successfully.")
  #       |> redirect(to: Routes.administrator_path(conn, :show, administrator))
  #
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, "edit.html", administrator: administrator, changeset: changeset)
  #   end
  # end

  def delete(conn, %{"id" => id}) do
    administrator = Administration.get_administrator!(id)
    {:ok, _administrator} = Administration.delete_administrator(administrator)

    conn
    |> put_flash(:info, "Administrator deleted successfully.")
    |> redirect(to: Routes.administrator_path(conn, :index))
  end
end
