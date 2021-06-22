# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Sample configuration:
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]
#
# By default, the umbrella project as well as each child
# application will require this configuration file, as
# configuration and dependencies are shared in an umbrella
# project. While one could configure all applications here,
# we prefer to keep the configuration of each individual
# child application in their own app, but all other
# dependencies, regardless if they belong to one or multiple
# apps, should be configured in the umbrella to avoid confusion.
import_config "../apps/dashboard/config/config.exs"
import_config "../apps/hub_cluster/config/config.exs"
import_config "../apps/hub_crm/config/config.exs"
import_config "../apps/hub_identity/config/config.exs"
import_config "../apps/hub_ledger/config/config.exs"
import_config "../apps/hub_payments/config/config.exs"

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

config :sendgrid,
  api_key: {:system, "SENDGRID_API_KEY"}

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

# Use Hub Identity Authentication
config :hub_identity_elixir, :url, "https://stage-identity.hubsynch.com"
config :hub_identity_elixir, :public_key, "pub_wr2EZlceaEjIJNnu21elGFCKIsNhZK8pTybrwBTKDGw"
config :hub_identity_elixir, :private_key, System.get_env("HUBLEDGER_HUBIDENTITY_API_KEY")

config :codepagex, :encodings, [
  "VENDORS/MICSFT/WINDOWS/CP932"
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# import_config "#{Mix.env()}.exs"

config :hub_identity_elixir, :private_key, System.get_env("HUBLEDGER_HUBIDENTITY_API_KEY")
