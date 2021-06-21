use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hub_payments, HubPayments.Repo,
  username: "postgres",
  password: "postgres",
  database: "hub_payments_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hub_payments, HubPaymentsWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "Q+OP19O2U0NIS7k9U3NLm/zj66PK7tkUQokVLQXU3Qda4gwpgpLqyN6mx+cJj7ND",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

import_config "test.secret.exs"
