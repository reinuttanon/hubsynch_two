# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HubPayments.Repo.insert!(%HubPayments.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias HubPayments.Shared

settings = [
  %{
    active: true,
    env: "development",
    key: "paygent_cacertfile",
    type: "file_path",
    value: "/priv/certs"
  },
  %{
    active: true,
    env: "development",
    key: "paygent_certfile",
    type: "file_path",
    value: "/priv/certs"
  },
  %{
    active: true,
    env: "development",
    key: "paygent_password",
    type: "secret",
    value: "paygent_password"
  },
  %{
    active: true,
    env: "development",
    key: "paygent_url",
    type: "url",
    value: "paygent_url"
  },
  %{
    active: true,
    env: "development",
    key: "sbps_basic_id",
    type: "file_path",
    value: "sbps_basic_id"
  },
  %{
    active: true,
    env: "development",
    key: "sbps_hash_key",
    type: "file_path",
    value: "sbps_hash_key"
  },
  %{
    active: true,
    env: "development",
    key: "sbps_url",
    type: "url",
    value: "sbps_url"
  }
]

for setting <- settings do
  Shared.create_setting(setting)
end
