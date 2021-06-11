# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hub_ledger, HubLedgerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pljvBt5UXkTkb7U87NYHyg9+4NBVmNTWJ3RfzCoxLrxnbtD0a3fHzTsownzxzfL8",
  render_errors: [view: HubLedgerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HubLedger.PubSub,
  live_view: [signing_salt: "WipjU5gg"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Get your money right with config
config :money,
  default_currency: :JPY,
  separator: ",",
  fractional_unit: true,
  strip_insignificant_zeros: false,
  custom_currencies: [
    HIP: %{name: "Hivelocity Points", symbol: "HiP", exponent: 0, symbol_on_right: true}
  ]

# Sendgrid config
config :sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}

# Use Hub Identity Authentication
config :hub_identity_elixir, :url, "https://stage-identity.hubsynch.com"
config :hub_identity_elixir, :public_key, "pub_wr2EZlceaEjIJNnu21elGFCKIsNhZK8pTybrwBTKDGw"
config :hub_identity_elixir, :private_key, "prv_8LLU2MLOEhorgagSmKz0zTpwwkjcvfSXsF-dtCmB1E8"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
