defmodule HubLedgerWeb.TransactionController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Ledgers

  def index(conn, _) do
    transactions =
      Ledgers.list_transactions()
      |> Enum.sort_by(& &1.inserted_at, :desc)

    render(conn, "index.html", transactions: transactions)
  end

  def show(conn, %{"id" => id}) do
    transaction = Ledgers.get_transaction!(id)

    render(conn, "show.html", %{transaction: transaction})
  end
end
