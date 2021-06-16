defmodule HubLedgerWeb.AccountController do
  @moduledoc false

  use HubLedgerWeb, :controller

  alias HubLedger.Accounts

  def index(conn, _) do
    accounts = Accounts.list_accounts()
    render(conn, "index.html", accounts: accounts)
  end

  def new(conn, _) do
    changeset = Accounts.new_account()
    render(conn, "new.html", changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    changeset = Accounts.change_account(account, %{})
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Accounts.create_account(account_params) do
      {:ok, %{account: account}} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.account_path(conn, :show, account))

      {:error, :account, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Accounts.get_account!(id)
    render(conn, "show.html", %{account: account})
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Accounts.get_account!(id)

    case Accounts.update_account(account, account_params) do
      {:ok, updated_account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: Routes.account_path(conn, :show, updated_account))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def delete(_conn, _) do
    # api_key = ClientServices.get_api_key!(id)
    # {:ok, _api_key} = ClientServices.delete_api_key(api_key)

    # conn
    # |> put_flash(:info, "Api key deleted successfully.")
    # |> redirect(to: Routes.api_key_path(conn, :index))
  end
end
