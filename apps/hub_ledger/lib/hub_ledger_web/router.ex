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
    plug HubLedgerWeb.Authentication.ApiAuth
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

  # Other scopes may use custom stacks.
  # scope "/api", HubLedgerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: HubLedgerWeb.Telemetry
    end
  end
end
