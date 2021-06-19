defmodule HubPaymentsWeb.Router do
  use HubPaymentsWeb, :router

  import HubPaymentsWeb.Authentication.UserAuth

  pipeline :public_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HubPaymentsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_ledger_user
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HubPaymentsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug HubPaymentsWeb.Authentication.UserAuth
    plug :put_secure_browser_headers
  end

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug HubIdentityWeb.Authentication.ApiAuth, type: "private"

  scope "/", HubPaymentsWeb do
    pipe_through [:public_browser, :redirect_if_user_is_authenticated]
    get "/", PageController, :index
    # get "/sessions/index", SessionController, :index
    # get "/sessions/new", SessionController, :new
    # get "/sessions/log_in", SessionController, :create
  end

  scope "/", HubPaymentsWeb do
    pipe_through :browser

    live "/settings", SettingLive.Index, :index
    live "/settings/new", SettingLive.Index, :new
    live "/settings/:id/edit", SettingLive.Index, :edit

    live "/settings/:id", SettingLive.Show, :show
    live "/settings/:id/show/edit", SettingLive.Show, :edit

    live "/", PageLive, :index
    live "/providers", ProviderLive.Index, :index
    live "/providers/new", ProviderLive.Index, :new
    live "/providers/:id/edit", ProviderLive.Index, :edit

    live "/providers/:id", ProviderLive.Show, :show
    live "/providers/:id/show/edit", ProviderLive.Show, :edit
  end

  scope "/api/v1", HubPaymentsWeb.Api.V1 do
    pipe_through [:auth_api]

    post "/payments/process", PaymentController, :process
  end
end
