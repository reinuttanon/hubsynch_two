defmodule HubLedgerWeb.AccountControllerTest do
  use HubLedgerWeb.ConnCase
  import HubLedger.Factory

  alias HubLedger.Accounts

  setup :register_and_log_in_administrator

  describe "GET /" do
    test "renders new Account page", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :new))
      response = html_response(conn, 200)

      assert response =~ "<h1>New Account</h1>"
    end

    test "renders edit Account page", %{conn: conn} do
      account = insert(:account)
      conn = get(conn, Routes.account_path(conn, :edit, account.id))
      response = html_response(conn, 200)

      assert response =~ "<h1>Edit Account</h1>"
    end

    test "renders index Account page", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      response = html_response(conn, 200)
      assert response =~ "Accounts"
    end
  end

  describe "POST /" do
    test "Creates an account with valid params", %{conn: conn} do
      account_params = %{currency: "JPY", name: "ErinTest", type: "equity"}

      conn
      |> post("/accounts", %{account: account_params})

      [account] = Accounts.list_accounts()

      assert account.currency == account_params.currency
      assert account.name == account_params.name
      assert account.type == account_params.type
    end

    test "redirect to new account view with invalid params", %{conn: conn} do
      account_params = %{currency: "invalid_currency", name: "ErinTest", type: "invalid_type"}

      conn =
        conn
        |> post("/accounts", %{account: account_params})

      response = html_response(conn, 200)
      accounts = Accounts.list_accounts()

      assert length(accounts) == 0
      assert response =~ "<h1>New Account</h1>"
    end
  end

  describe "PATCH /" do
    test "updates the account with valid params", %{conn: conn} do
      account = insert(:account)
      account_params = %{active: false, name: "new_name"}

      conn
      |> patch("/accounts/#{account.id}", %{account: account_params})

      [updated_account] = Accounts.list_accounts()

      assert updated_account.active != account.active
      assert updated_account.name != account.name

      assert updated_account.name == "new_name"
      assert updated_account.active == false
    end

    test "redirect to edit.html with invalid params", %{conn: conn} do
      account = insert(:account)
      account_params = %{active: "invalid_value", name: "new_name"}

      conn =
        conn
        |> patch("/accounts/#{account.id}", %{account: account_params})

      response = html_response(conn, 200)
      [updated_account] = Accounts.list_accounts()

      assert response =~ "<h1>Edit Account</h1>"

      assert updated_account.active == account.active
      assert updated_account.name == account.name

      assert updated_account.name != "new_name"
      assert updated_account.active != false
    end
  end
end
