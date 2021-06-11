defmodule HubLedgerWeb.Api.V1.JournalEntryView do
  use HubLedgerWeb, :view

  def render("success.json", %{total: total}) do
    %{
      status: "success",
      total_transactions: total
    }
  end
end
