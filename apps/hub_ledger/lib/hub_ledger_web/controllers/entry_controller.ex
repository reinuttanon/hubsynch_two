defmodule HubLedgerWeb.EntryController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Ledgers

  def index(conn, _) do
    entries =
      Ledgers.list_entries()
      |> Enum.sort_by(& &1.inserted_at, :desc)

    render(conn, "index.html", entries: entries)
  end

  def show(conn, %{"id" => id}) do
    entry = Ledgers.get_entry!(id)

    render(conn, "show.html", %{entry: entry})
  end
end
