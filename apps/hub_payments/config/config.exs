# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hub_payments,
  ecto_repos: [HubPayments.Repo]

# Configures the endpoint
config :hub_payments, HubPaymentsWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: HubPaymentsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: HubPayments.PubSub,
  live_view: [signing_salt: "9MTqXf+6"]

# # Get your money right with config
# config :money,
#   default_currency: :JPY,
#   separator: ",",
#   fractional_unit: true,
#   strip_insignificant_zeros: false,
#   custom_currencies: [
#     HIP: %{name: "Hivelocity Points", symbol: "HiP", exponent: 0, symbol_on_right: true}
#   ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
