use Mix.Config

config :libcluster,
  topologies: [
    localhost: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [String.to_atom(System.get_env("VAULT_NODE_NAME") || "vault@localhost")]]
    ]
  ]
