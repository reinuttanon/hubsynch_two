defmodule HubCrm.Repo do
  use Ecto.Repo,
    otp_app: :hub_crm,
    adapter: Ecto.Adapters.Postgres
end
