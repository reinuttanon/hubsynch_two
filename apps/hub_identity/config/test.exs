use Mix.Config

# Configure the Repos to migrate, drop, etc
config :hub_identity,
  ecto_repos: [HubIdentity.Repo]

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hub_identity, HubIdentity.Repo,
  username: "postgres",
  password: "postgres",
  database: "hub_identity_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hub_identity, HubIdentityWeb.Endpoint,
  http: [port: 4002],
  server: false,
  secret_key_base: "wsX8Hsuy5IhCxpYOV0xBOi7NgfjCfylyX+ceIxqK/WmR/Mee1RJJOdpJObm6JgPc"

# Print only warnings and errors during test
config :logger, level: :warn

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Sendgrid config
config :sendgrid,
  api_key: "test_api"

# Open Auth redirect url
config :hub_identity, redirect_host: "http://test.com"

config :hub_identity, async_cast: false

config :hub_identity, http: HubIdentity.HttpTester
config :hub_identity, email: HubIdentity.EmailTester

config :hub_identity, IdentitySynch.Identities.UserNotifier, adapter: Bamboo.TestAdapter
