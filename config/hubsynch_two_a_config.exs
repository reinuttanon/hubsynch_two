import Config

config :kernel,
  [{:distributed, [{:hubsynch_two_a, 5000, [:hubsynch_two_a, {:hubsynch_two_b, :hubsynch_two_c}]}]},
   {:sync_nodes_mandatory, [:hubsynch_two_b, :hubsynch_two_c]},
   {:sync_nodes_timeout, 5000}
  ]
 }
