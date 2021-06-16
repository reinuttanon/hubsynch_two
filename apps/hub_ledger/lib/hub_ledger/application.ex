defmodule HubLedger.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repositories
      HubLedger.Repo,
      # Start the Telemetry supervisor
      HubLedgerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HubLedger.PubSub},
      # Start the balance server to ensure running balances are correct
      HubLedger.Accounts.BalanceServer,
      # Start the Endpoint (http/https)
      HubLedgerWeb.Endpoint
      # Start a worker by calling: HubLedger.Worker.start_link(arg)
      # {HubLedger.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HubLedger.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HubLedgerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
