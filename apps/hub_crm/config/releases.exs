# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

hubsynch_database_url =
  System.get_env("HUBSYNCH_DATABASE_URL") ||
    raise """
    environment variable HUBSYNCH_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

identity_database_url =
  System.get_env("HUBIDENTITY_DATABASE_URL") ||
    raise """
    environment variable HUBIDENTITY_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

database_url =
  System.get_env("DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable HUBCRM_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :hub_crm, HubCrmWeb.Endpoint, secret_key_base: secret_key_base

config :hub_crm, HubCrm.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("REPO_POOL_SIZE") || "10")

config :hub_crm, HubCrm.HubIdentityRepo,
  url: identity_database_url,
  pool_size: 5

config :hub_crm, HubCrm.HubsynchRepo,
  url: hubsynch_database_url,
  pool_size: 5

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :hub_crm, HubCrmWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
