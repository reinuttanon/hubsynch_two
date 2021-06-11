defmodule HubLedgerWeb.Api.V1.FallbackView do
  @moduledoc false
  use HubLedgerWeb, :view

  def render("error.json", %{error: %{entry: entry, transactions: transactions}}) do
    %{
      error: %{
        entry: entry,
        transactions: transactions
      }
    }
  end

  def render("error.json", %{error: %{transactions: transactions}}) do
    %{
      error: %{
        transactions: transactions
      }
    }
  end

  def render("error.json", %{error: message}) do
    %{error: message}
  end
end
