defmodule HubLedgerWeb.Router do
  use HubLedgerWeb, :router

  import HubLedgerWeb.Authentication.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HubLedgerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HubLedgerWeb.Authentication.UserAuth
    plug :fetch_current_ledger_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug HubIdentityWeb.Authentication.ApiAuth, type: "private"
  end

  pipeline :public_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HubLedgerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_ledger_user
  end

  scope "/", HubLedgerWeb do
    pipe_through [:browser]

    resources "/accounts", AccountController
    resources "/entry_builders", EntryBuilderController
    resources "/entries", EntryController, only: [:index, :show]
    resources "/transactions", TransactionController, only: [:index, :show]
    resources "/entry_builders", EntryBuilderController

    post "/downloads/csv", DownloadController, :csv_download

    live "/reports/accounts", ReportsLive.Account, :index
    live "/reports/accounts/view_sample", ReportsLive.Account, :view_sample
    live "/reports/entries", ReportsLive.Entry, :index
    live "/reports/entries/view_sample", ReportsLive.Entry, :view_sample
    live "/reports/transactions", ReportsLive.Transaction, :index
    live "/reports/transactions/view_sample", ReportsLive.Transaction, :view_sample

    get "/sessions/log_out", SessionController, :log_out

    get "/ledger_dashboard", DashboardController, :index

    get "/users/confirm", UserConfirmationController, :confirm
  end

  scope "/", HubLedgerWeb do
    pipe_through [:public_browser, :redirect_if_user_is_authenticated]
    get "/", PageController, :index
    get "/sessions/index", SessionController, :index
    get "/sessions/new", SessionController, :new
    get "/sessions/log_in", SessionController, :create
  end

  scope "/api/v1", HubLedgerWeb.Api.V1, as: :api_v1 do
    pipe_through [:api]

    post "/journal_entry/process/:uuid", JournalEntryController, :process
    post "/journal_entry", JournalEntryController, :create

    get "/accounts/:uuid/balance", AccountController, :balance
    get "/accounts/:uuid/running_balance", AccountController, :running_balance
    post "/accounts", AccountController, :create
  end
end
