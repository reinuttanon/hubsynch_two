defmodule HubLedgerWeb.Api.V1.JournalEntryController do
  use HubLedgerWeb, :api_controller

  alias HubLedger.Ledgers

  def process(conn, %{"uuid" => uuid, "payload" => payload}) do
    with {:ok, %{transactions: {total, _}}} <- Ledgers.create_journal_entry(payload, uuid) do
      render(conn, "success.json", %{total: total})
    else
      {:error, message} -> {:error, message}
    end
  end

  def process(conn, %{"uuid" => uuid, "payload" => payload, "safe" => true}) do
    with {:ok, %{transactions: {total, _}}} <- Ledgers.safe_journal_entry(payload, uuid) do
      render(conn, "success.json", %{total: total})
    else
      {:error, message} -> {:error, message}
    end
  end

  def create(conn, %{"payload" => %{"entry" => entry, "transactions" => transactions}}) do
    with {:ok, %{entry: _entry, transactions: {total, _transactions}}} <-
           Ledgers.journal_entry(entry, transactions) do
      render(conn, "success.json", %{total: total})
    end
  end
end
