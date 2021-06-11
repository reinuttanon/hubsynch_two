defmodule HubLedger.Repo do
  use Ecto.Repo,
    otp_app: :hub_ledger,
    adapter: Ecto.Adapters.Postgres
end
