use Mix.Config
# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
config :hub_payments, HubPaymentsWeb.Endpoint, server: true

config :hub_payments, :http_module, HTTPoison

config :hub_payments, :sbps_key, System.get_env("SBPS_KEY")
config :hub_payments, :sbps_iv, System.get_env("SBPS_IV")
config :hub_payments, :sbps_hash_key, System.get_env("SBPS_HASH_KEY")
config :hub_payments, :sbps_basic_id, System.get_env("SBPS_BASIC_ID")
config :hub_payments, :sbps_url, "https://stbfep.sps-system.com/api/xmlapi.do"

config :hub_payments, :paygent_cacertfile, "priv/certs/curl-ca-bundle20160624.crt"
config :hub_payments, :paygent_certfile, "priv/certs/Mdev-20180516_client_cert.pem"
config :hub_payments, :paygent_password, System.get_env("PAYGENT_PASSWORD")
config :hub_payments, :paygent_url, "https://sandbox.paygent.co.jp/n/card/request"

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :hub_payments, HubPaymentsWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#         transport_options: [socket_opts: [:inet6]]
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :hub_payments, HubPaymentsWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.
