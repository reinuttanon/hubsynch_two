# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

database_url =
  System.get_env("HUBPAYMENTS_DATABASE_URL") ||
    raise """
    environment variable HUBPAYMENTS_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("HUBPAYMENTS_SECRET_KEY_BASE") ||
    raise """
    environment variable HUBPAYMENTS_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :hub_payments, HubPaymentsWeb.Endpoint, secret_key_base: secret_key_base

config :hub_payments, HubPayments.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("HUBPAYMENTS_POOL_SIZE") || "10")

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
config :hub_payments, HubPaymentsWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
