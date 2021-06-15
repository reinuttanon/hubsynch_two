defmodule HubCrmWeb.Router do
  use HubCrmWeb, :router

  pipeline :auth_api do
    plug :accepts, ["json"]
    plug HubIdentityWeb.Authentication.ApiAuth, type: "private"
  end

  scope "/api/v1", HubCrmWeb.Api.V1 do
    pipe_through [:auth_api]

    get "/support/countries", SupportController, :countries
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
end
