# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hub_identity, HubIdentityWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HubIdentityWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HubIdentity.PubSub,
  live_view: [signing_salt: "4t1KmVhu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :hub_identity, HubIdentity.Encryption.Tokens,
  issuer: "HubIdentity",
  allowed_algos: ["RS256"],
  secret_fetcher: HubIdentity.Encryption.JWKCertServer

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

# Sendgrid config
config :sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
