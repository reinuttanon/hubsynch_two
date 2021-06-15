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

    live "/", PageLive, :index
    live "/providers", ProviderLive.Index, :index
    live "/providers/new", ProviderLive.Index, :new
    live "/providers/:id/edit", ProviderLive.Index, :edit

    live "/providers/:id", ProviderLive.Show, :show
    live "/providers/:id/show/edit", ProviderLive.Show, :edit
  end
end
