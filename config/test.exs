use Mix.Config
# Print only warnings and errors during test
config :logger, level: :critical

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Sendgrid config
config :sendgrid,
  api_key: "test_api"
