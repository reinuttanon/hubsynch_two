use Mix.Config
# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hub_ledger, HubLedger.Repo,
  username: "postgres",
  password: "postgres",
  database: "hub_ledger_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hub_ledger, HubLedgerWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "pljvBt5UXkTkb7U87NYHyg9+4NBVmNTWJ3RfzCoxLrxnbtD0a3fHzTsownzxzfL8",
  server: false

config :hub_ledger, hub_identity: HubLedger.HttpTester
config :hub_ledger, hub_identity_user: HubLedger.HttpTester

config :hub_ledger, email: HubLedger.EmailTester

# Sendgrid config
config :sendgrid,
  api_key: "test_api"

# Print only warnings and errors during test
config :logger, level: :warn
