defmodule HubIdentity.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :hub_identity,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, warn: false

  def all_present(query) do
    query
    |> nil_query()
    |> all()
  end

  def get_present!(schema, id) do
    query =
      from s in schema,
        where: s.id == ^id

    nil_query(query)
    |> one!()
  end

  def one_present(query) do
    query
    |> nil_query()
    |> one()
  end

  def one_present!(query) do
    query
    |> nil_query()
    |> one!()
  end

  defp nil_query(query) do
    from q in query,
      where: is_nil(q.deleted_at)
  end
end
