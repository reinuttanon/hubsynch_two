defmodule HubIdentity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HubIdentity.Repo,
      # Start the countries cache
      HubIdentity.Providers.GoogleCertsServer,
      # Start the JWK certs server
      HubIdentity.Encryption.JWKCertServer,
      # Start the Metrics server
      HubIdentity.Metrics.MetricServer,
      # Start the state_secrets cache
      HubIdentity.ClientServices.StateServer,
      # Start the cookie server
      HubIdentityWeb.Authentication.AccessCookiesServer,
      # Start the verification code server
      HubIdentity.Verifications.VerificationCodeServer,
      # Start the email verify reference
      HubIdentity.Verifications.EmailVerifyReferenceServer,
      # Start the Telemetry supervisor
      HubIdentityWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HubIdentity.PubSub},
      # Start the Endpoint (http/https)
      HubIdentityWeb.Endpoint,
      # Start a worker by calling: HubIdentity.Worker.start_link(arg)
      # {HubIdentity.Worker, arg}
      # Start the Oauth Provider cache
      HubIdentity.Providers.ProviderServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HubIdentity.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HubIdentityWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
