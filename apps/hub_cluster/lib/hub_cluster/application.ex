defmodule HubCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    topologies = [
      localhost: [
        strategy: Cluster.Strategy.Epmd,
        config: [hosts: [:hub_vault]]
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: HubCluster.ClusterSupervisor]]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HubCluster.Supervisor)
  end
end

# iex --name a -S mix phx.server

# export HUBIDENTITY_PORT=4006
# export HUBCRM_PORT=4007
# export HUBPAYMENTS_PORT=4008
# export HUBLEDGER_PORT=4009

# iex --name b -S mix phx.server

# Node.connect(:"a@Erins-MacBook-Pro.local")

# HubCluster.Application.connect_nodes()

# :"hub_vault@ip-10-11-10-198"
# :"hubsynch_two@ip-10-11-10-198"
