defmodule HubCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Cluster.Supervisor,
       [Application.get_env(:libcluster, :topologies), [name: HubCluster.ClusterSupervisor]]},
      # Start the Memento repo
      HubCluster.MementoRepo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: HubCluster.Supervisor)
  end
end
