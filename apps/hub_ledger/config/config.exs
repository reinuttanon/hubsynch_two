# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config
# Configure the Repos to migrate, drop, etc
config :hub_ledger,
  ecto_repos: [HubLedger.Repo]

# Configures the endpoint
config :hub_ledger, HubLedgerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HubLedgerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HubLedger.PubSub,
  live_view: [signing_salt: "WipjU5gg"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
