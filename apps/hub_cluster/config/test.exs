use Mix.Config

config :libcluster,
  topologies: [
    localhost: [
      strategy: Cluster.Strategy.Epmd
    ]
  ]

config :hub_cluster, :mnesia_manager, node()

config :hub_cluster, :mnesia_options, []

# # The function to use for connecting nodes. The node
# # name will be appended to the argument list. Optional
# connect: {:net_kernel, :connect_node, []},
# # The function to use for disconnecting nodes. The node
# # name will be appended to the argument list. Optional
# disconnect: {:erlang, :disconnect_node, []},
# # The function to use for listing nodes.
# # This function must return a list of node names. Optional
# list_nodes: {:erlang, :nodes, [:connected]}
