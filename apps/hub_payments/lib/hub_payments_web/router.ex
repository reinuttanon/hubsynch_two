defmodule HubPaymentsWeb.Router do
  use HubPaymentsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HubPaymentsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
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

  # Other scopes may use custom stacks.
  # scope "/api", HubPaymentsWeb do
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
      live_dashboard "/dashboard", metrics: HubPaymentsWeb.Telemetry
    end
  end
end
