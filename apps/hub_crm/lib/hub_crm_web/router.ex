defmodule HubCrmWeb.Router do
  use HubCrmWeb, :router

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug HubCrmWeb.Plugs.ApiAuth
  end

  scope "/api/v1", HubCrmWeb.Api.V1 do
    pipe_through [:auth_api]

    post "/users", HubsynchUsersController, :create
    get "/users", HubsynchUsersController, :show
    get "/users/:user_id", HubsynchUsersController, :show
    put "/users/:user_id", HubsynchUsersController, :update
    delete "/users/:user_id", HubsynchUsersController, :delete

    post "/users/:user_id/addresses", HubsynchAddressController, :create
    get "/users/:user_id/addresses", HubsynchAddressController, :index
    get "/users/:user_id/addresses/:address_id", HubsynchAddressController, :show
    put "/users/:user_id/addresses/:address_id", HubsynchAddressController, :update
    delete "/users/:user_id/addresses/:address_id", HubsynchAddressController, :delete

    get "/support/countries", SupportController, :countries
    get "/support/occupations", SupportController, :occupations
    get "/support/prefectures", SupportController, :prefectures
  end

  scope "/api/v1", HubCrmWeb.Api.V1 do
    pipe_through [:auth_api]

    get "/callbacks/hub_identity", CallbackController, :show
  end

  scope "/api/v2", HubCrmWeb.Api.V2 do
    pipe_through [:auth_api]

    post "/users", UserController, :create
    get "/users/:uuid", UserController, :show
    put "/users/:uuid", UserController, :update
    delete "/users/:uuid", UserController, :delete

    post "/users/:user_uuid/addresses", AddressController, :create
    get "/users/:user_uuid/addresses", AddressController, :index
    get "/users/:user_uuid/addresses/:uuid", AddressController, :show
    put "/users/:user_uuid/addresses/:uuid", AddressController, :update
    delete "/users/:user_uuid/addresses/:uuid", AddressController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", HubCrmWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router
  #
  #   scope "/" do
  #     pipe_through :browser
  #     live_dashboard "/dashboard", metrics: HubCrmWeb.Telemetry
  #   end
  # end
end
