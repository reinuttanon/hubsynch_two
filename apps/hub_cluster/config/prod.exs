use Mix.Config

config :libcluster,
  topologies: [
    localhost: [
      strategy: Cluster.Strategy.LocalEpmd,
      config: [
        hosts: [
          String.to_atom(System.get_env("VAULT_NODE_NAME") || "vault@localhost"),
          String.to_atom(System.get_env("MNESIA_MANAGER") || "mnesia_manager@localhost")
        ]
      ]
    ]
  ]

config :hub_cluster,
       :mnesia_manager,
       String.to_atom(System.get_env("MNESIA_MANAGER") || "mnesia_manager@localhost")

config :hub_cluster, :mnesia_options, [
  {:disc_copies,
   [String.to_atom(System.get_env("MNESIA_MANAGER") || "mnesia_manager@localhost")]},
  {:majority, true},
  {:ram_copies, [node()]}
]
