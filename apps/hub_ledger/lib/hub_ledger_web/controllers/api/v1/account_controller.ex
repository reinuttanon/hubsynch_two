defmodule HubLedgerWeb.Api.V1.AccountController do
  @moduledoc false

  use HubLedgerWeb, :api_controller
  alias HubLedger.Accounts
  alias HubLedger.Accounts.{Account, Balance}

  def create(conn, %{"account" => account_params}) do
    with {:ok, %{account: account}} <- Accounts.create_account(account_params) do
      render(conn, "show.json", %{uuid: account.uuid})
    else
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  def balance(conn, %{"uuid" => uuid}) do
    with %Money{amount: amount, currency: currency} <- Accounts.get_account_balance(%{uuid: uuid}) do
      render(conn, "balance.json", %{amount: amount, currency: currency, uuid: uuid})
    end
  end

  def running_balance(conn, %{"uuid" => uuid}) do
    with %Account{id: account_id} <- Accounts.get_account(%{uuid: uuid}),
         %Balance{kind: kind, money: money} <- Accounts.get_balance!(%{account_id: account_id}) do
      render(conn, "running_balance.json", %{
        kind: kind,
        amount: money.amount,
        currency: money.currency,
        uuid: uuid
      })
    else
      nil -> {:error, "Account not found"}
    end
  end
end
