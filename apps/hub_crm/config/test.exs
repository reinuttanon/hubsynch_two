use Mix.Config
# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hub_crm, HubCrm.Repo,
  username: "postgres",
  password: "postgres",
  database: "hub_crm_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hub_crm, HubCrmWeb.Endpoint,
  http: [port: 4003],
  secret_key_base: "o7GhEKUlQU4YAnDTBbSzBcSq0J4D7DBWSUdwBtL2PJf33gMUFTKopy/ZFFE1gOhl",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1
