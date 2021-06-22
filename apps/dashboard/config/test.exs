use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dashboard, DashboardWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "MZHmtHjHUpFWxUks7IjQFZCN+gx6bpMTvRd9NKGS8kjIq6Va6ngxwOV2SPGra66g",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
