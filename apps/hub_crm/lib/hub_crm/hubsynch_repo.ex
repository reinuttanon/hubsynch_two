defmodule HubCrm.HubsynchRepo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :hub_crm,
    adapter: Ecto.Adapters.MyXQL
end
