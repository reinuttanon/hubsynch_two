defmodule HubPayments.Repo do
  use Ecto.Repo,
    otp_app: :hub_payments,
    adapter: Ecto.Adapters.Postgres
end
