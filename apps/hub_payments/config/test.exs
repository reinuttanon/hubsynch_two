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

config :hub_payments, :default_key_id, 1
config :hub_payments, :default_key, "CEkcWrYAdS7pLC5w/xbf4zB2fH14R8on0xdjbIFYK6s="
config :hub_payments, :sha_3_key, "o7yT24bQN+HnzFcnFBv8G3d7xq2WK1dlTSB0Qvv3MwA="
config :hub_payments, :blake_2_key, "ZTPnOC2T+eLrLiTKEc3KrjZyDYsOj6TzE39RaO65GkQ="
config :hub_payments, :total_keys, 64
config :hub_payments, :http_module, HubVault.Providers.MockHttp
# config :hub_payments, :http_module, HTTPoison
config :hub_payments, :sbps_key, "sbps_key"
config :hub_payments, :sbps_iv, "sbps_iv"
config :hub_payments, :sbps_hash_key, "sbps_hash_key"
config :hub_payments, :sbps_basic_id, "sbps_basic_id"
config :hub_payments, :sbps_url, "https://stbfep.sps-system.com/api/xmlapi.do"
config :hub_payments, :paygent_cacertfile, "paygent_cacertfile"
config :hub_payments, :paygent_certfile, "paygent_certfile"
config :hub_payments, :paygent_password, 'paygent_password'
config :hub_payments, :paygent_url, "https://sandbox.paygent.co.jp/n/card/request"
config :hub_payments, :hubsynch_api_key, "hubsynch_api_key"

config :hub_payments, :http_module, HubPayments.Providers.MockHttp

config :hub_payments, :merchant_id, "some_merchant_id"
config :hub_payments, :connect_id, "some_connect_id"
config :hub_payments, :connect_password, "some_connect_password"

config :hub_payments, vault_rpc: false
