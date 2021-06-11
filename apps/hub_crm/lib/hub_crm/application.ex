defmodule HubCrm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      HubCrm.Repo,
      # Start the Ecto Hubsynch repository
      # HubCrm.HubsynchRepo,
      # Start the Ecto HubIdentity repository
      HubCrm.HubIdentityRepo,
      # Start the countries cache
      HubCrm.Countries.CountryServer,
      # Start the Telemetry supervisor
      HubCrmWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HubCrm.PubSub},
      # Start the Endpoint (http/https)
      HubCrmWeb.Endpoint
      # Start a worker by calling: HubCrm.Worker.start_link(arg)
      # {HubCrm.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HubCrm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HubCrmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
