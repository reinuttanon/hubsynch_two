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

providers = [
  %{
    name: "paygent",
    credentials: %{},
    url: "https://sandbox.paygent.co.jp/n/card/request"
  },
  %{
    name: "sbps",
    credentials: %{},
    url: "https://stbfep.sps-system.com/api/xmlapi.do"
  }
]

for provider <- providers do
  case HubPayments.Providers.get_provider(%{name: provider.name}) do
    nil -> HubPayments.Providers.create_provider(provider)
    _ -> nil
  end
end



wallet_params = %{
  owner: %{
    object: "HubIdentity.User",
    uid: "user_12345678"
  }
}

{:ok, wallet} =
  case HubPayments.Wallets.get_wallet(%{owner: wallet_params.owner}) do
    [] -> HubPayments.Wallets.create_wallet(wallet_params)
    [found | _] -> {:ok, found}
  end

HubPayments.Wallets.create_credit_card(%{
  brand: "visa",
  exp_month: "01",
  exp_year: "23",
  fingerprint: "this is a long fingerprint with a swirl",
  last_four: "4321",
  wallet_id: wallet.id
})
