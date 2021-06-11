defmodule HubLedgerWeb.EntryBuilderController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Ledgers
  alias HubLedger.Ledgers.EntryBuilder

  def index(conn, _) do
    entry_builders = Ledgers.list_entry_builders()
    render(conn, "index.html", entry_builders: entry_builders)
  end

  def new(conn, _) do
    changeset = Ledgers.change_entry_builder(%EntryBuilder{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    entry_builder = get_entry_builder(id)
    changeset = Ledgers.change_entry_builder(entry_builder, %{})
    render(conn, "edit.html", entry_builder: entry_builder, changeset: changeset)
  end

  def create(conn, %{"entry_builder" => entry_builder_params}) do
    case Ledgers.create_entry_builder(entry_builder_params) do
      {:ok, entry_builder} ->
        conn
        |> put_flash(:info, "Entry Builder created successfully.")
        |> redirect(to: Routes.entry_builder_path(conn, :show, entry_builder))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    entry_builder = get_entry_builder(id)
    render(conn, "show.html", entry_builder: entry_builder)
  end

  def update(conn, %{"id" => id, "entry_builder" => entry_builder_params}) do
    entry_builder = Ledgers.get_entry_builder!(id)

    case Ledgers.update_entry_builder(entry_builder, entry_builder_params) do
      {:ok, updated_entry_builder} ->
        conn
        |> put_flash(:info, "Entry Builder updated successfully.")
        |> redirect(to: Routes.entry_builder_path(conn, :show, updated_entry_builder))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", entry_builder: entry_builder, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    entry_builder = Ledgers.get_entry_builder!(id)
    {:ok, _entry_builder} = Ledgers.delete_entry_builder(entry_builder)

    conn
    |> put_flash(:info, "Entry Builder deleted successfully.")
    |> redirect(to: Routes.entry_builder_path(conn, :index))
  end

  defp get_entry_builder(id) do
    case Ledgers.get_entry_builder!(id) do
      %EntryBuilder{json_config: json_config} = entry_builder ->
        Map.put(entry_builder, :string_config, Jason.encode!(json_config))

      nil ->
        nil
    end
  end
end
