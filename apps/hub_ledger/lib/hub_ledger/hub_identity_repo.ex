defmodule HubLedger.HubIdentityRepo do
  use Ecto.Repo,
    otp_app: :hub_ledger,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false

  def one_present!(query) do
    query
    |> nil_query()
    |> one!()
  end

  def one_present(query) do
    query
    |> nil_query()
    |> one()
  end

  defp nil_query(query) do
    from q in query,
      where: is_nil(q.deleted_at)
  end
end
