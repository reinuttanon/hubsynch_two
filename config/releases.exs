import Config
# Dashboard runtime variables
secret_key_base =
  System.get_env("DASHBOARD_SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :dashboard, DashboardWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("DASHBOARD_PORT") || "D4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

# HubCrm runtime variables
config :hub_crm, HubCrmWeb.Endpoint,
  url: [host: System.get_env("HUBCRM_HOST"), scheme: "https", port: 443],
  http: [
    port: String.to_integer(System.get_env("HUBCRM_PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ]

database_url =
  System.get_env("HUBCRM_DATABASE_URL") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("HUBCRM_SECRET_KEY_BASE") ||
    raise """
    environment variable HUBCRM_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :hub_crm, HubCrmWeb.Endpoint, secret_key_base: secret_key_base

config :hub_crm, HubCrm.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("HUBCRM_REPO_POOL_SIZE") || "10")

# HubIdentity runtime variables
config :hub_identity, HubIdentityWeb.Endpoint,
  url: [host: System.get_env("HUBIDENTITY_HOST"), scheme: "https", port: 443],
  http: [
    port: String.to_integer(System.get_env("HUBIDENTITY_PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ]

config :hub_identity, redirect_host: "https://stage-identity.hubsynch.com"

identity_database_url =
  System.get_env("HUBIDENTITY_DATABASE_URL") ||
    raise """
    environment variable HUBIDENTITY_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("HUBIDENTITY_SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :hub_identity, HubIdentityWeb.Endpoint, secret_key_base: secret_key_base

config :hub_identity, HubIdentity.Repo,
  url: identity_database_url,
  pool_size: String.to_integer(System.get_env("HUBIDENTITY_REPO_POOL_SIZE") || "10")

# HubLedger runtime variables
# before starting your production server.
config :hub_ledger, HubLedgerWeb.Endpoint,
  url: [host: System.get_env("HUBLEDGER_HOST"), scheme: "https", port: 443],
  http: [
    port: String.to_integer(System.get_env("HUBLEDGER_PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ]

database_url =
  System.get_env("HUBLEDGER_DATABASE_URL") ||
    raise """
    environment variable HUBLEDGER_DATABASE_URL is missing.
    For example: ecto://USER:PASS@HOST/DATABASE
    """

secret_key_base =
  System.get_env("HUBLEDGER_SECRET_KEY_BASE") ||
    raise """
    environment variable HUBLEDGER_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :hub_ledger, HubLedgerWeb.Endpoint, secret_key_base: secret_key_base

config :hub_ledger, HubLedger.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("HUBLEDGER_POOL_SIZE") || "10")

# HubPayments runtime varabiles
config :hub_payments, HubPaymentsWeb.Endpoint,
  url: [host: System.get_env("HUBPAYMENTS_HOST"), scheme: "https", port: 443],
  http: [
    port: String.to_integer(System.get_env("HUBPAYMENTS_PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ]

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

config :libcluster,
  topologies: [
    localhost: [
      strategy: Cluster.Strategy.Epmd,
      config: [hosts: [String.to_atom(System.get_env("VAULT_NODE_NAME") || "vault@localhost")]]
    ]
  ]
