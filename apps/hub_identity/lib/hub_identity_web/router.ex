defmodule HubIdentityWeb.Router do
  @moduledoc false
  use HubIdentityWeb, :router

  import HubIdentityWeb.Authentication.AdministratorAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_administrator
  end

  pipeline :public_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {HubIdentityWeb.PublicUsersView, :app}
  end

  pipeline :public_api do
    plug :accepts, ["json"]
  end

  pipeline :public_key_api do
    plug :accepts, ["json"]

    plug HubIdentityWeb.Authentication.ApiAuth, type: "public"
  end

  pipeline :private_key_api do
    plug :accepts, ["json"]

    plug HubIdentityWeb.Authentication.ApiAuth, type: "private"
  end

  ## User public routes

  scope "/", HubIdentityWeb do
    pipe_through [:public_browser]

    get "/users/confirm/:token", UserConfirmationController, :confirm
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update

    get "/public_users/complete", PublicUsersController, :complete
    get "/privacy_policy/v1/", PageController, :privacy_policy
    get "/privacy_policy/v1/:lang", PageController, :privacy_policy
    get "/terms_of_service/v1/:lang", PageController, :terms_of_service

    get "/public_users/data_delete_confirmation/:uid",
        PublicUsersController,
        :data_delete_confirmation
  end

  ## Administer public routes

  scope "/", HubIdentityWeb do
    pipe_through [:browser]

    delete "/administrators/log_out", AdministratorSessionController, :delete
    get "/administrators/confirm", AdministratorConfirmationController, :new
    post "/administrators/confirm", AdministratorConfirmationController, :create
    get "/administrators/confirm/:token", AdministratorConfirmationController, :confirm
  end

  ## Administer authenticated routes

  scope "/", HubIdentityWeb do
    pipe_through [:browser, :redirect_if_administrator_is_authenticated]

    get "/", PageController, :index
    get "/administrators/log_in", AdministratorSessionController, :new
    post "/administrators/log_in", AdministratorSessionController, :create
    get "/administrators/reset_password", AdministratorResetPasswordController, :new
    post "/administrators/reset_password", AdministratorResetPasswordController, :create
    get "/administrators/reset_password/:token", AdministratorResetPasswordController, :edit
    put "/administrators/reset_password/:token", AdministratorResetPasswordController, :update
  end

  scope "/", HubIdentityWeb do
    pipe_through [:browser, :require_authenticated_administrator]

    get "/dashboard", DashboardController, :index

    get "/administrators/settings", AdministratorSettingsController, :edit
    put "/administrators/settings", AdministratorSettingsController, :update

    get "/administrators/settings/confirm_email/:token",
        AdministratorSettingsController,
        :confirm_email

    get "/client_services/:id/add_administrator", ClientServiceController, :add_administrator

    post "/client_services/:id/add_administrator",
         ClientServiceController,
         :add_administrator

    post "/client_services/:id/remove_administrator",
         ClientServiceController,
         :remove_administrator

    post "/client_services/:id/roll_api_keys",
         ClientServiceController,
         :roll_api_keys

    get "/client_services/:id/redirect_test", ClientServiceTestController, :redirect_test
    get "/client_services/:id/generate_redirect", ClientServiceTestController, :generate_redirect

    post "/client_services/:id/send_webhook", ClientServiceTestController, :send_webhook

    get "/documentation/jwt_docs", DocumentationController, :jwt_docs

    resources "/administrators", AdministratorController
    resources "/api_keys", ApiKeyController
    resources "/client_services", ClientServiceController
    resources "/provider_configs", ProviderConfigController
  end

  ## API routes
  ## Public key routes
  scope "/api/v1", HubIdentityWeb.Api.V1, as: :api_v1 do
    pipe_through [:public_api]

    get "/providers/oauth/response/:provider", ResponseController, :response
    get "/oauth_redirect_test", SupportController, :test_redirect
    get "/oauth/certs", SupportController, :certs
    post "/providers/oauth/token", ProviderController, :token

    post "/providers/oauth/data_delete_request/:provider",
         ResponseController,
         :delete_data_request
  end

  scope "/api/v1", HubIdentityWeb.Api.V1, as: :api_v1 do
    pipe_through [:public_key_api]

    get "/providers", ProviderController, :providers
    post "/providers/:provider", ProviderController, :authenticate

    post "/users", UserController, :create
    post "/users/reset_password", UserController, :reset_password
  end

  ## Private key routes
  scope "/api/v1", HubIdentityWeb.Api.V1, as: :api_v1 do
    pipe_through [:private_key_api]

    get "/current_user/:cookie_id", CurrentUserController, :show

    get "/users", UserController, :show
    post "/users/authenticate", UserController, :authenticate
    get "/users/:uid", UserController, :show
    post "/users/:uid/verification", VerificationController, :create
    put "/users/:uid/verification/validate", VerificationController, :validate
    post "/users/:uid/verification/renew", VerificationController, :renew
    delete "/users/:uid", UserController, :delete

    get "/users/:user_uid/emails", EmailController, :index
    post "/users/:user_uid/emails", EmailController, :create
    get "/users/:user_uid/emails/:uid", EmailController, :show

    put "/users/:user_uid/emails/change_primary_email/:uid",
        EmailController,
        :change_primary_email

    get "/users/emails/resend_confirmation",
        EmailController,
        :resend_confirmation

    delete "/users/:user_uid/emails/:uid", EmailController, :delete
  end

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
      live_dashboard "/elixir_dashboard", metrics: HubIdentityWeb.Telemetry
    end
  end
end
