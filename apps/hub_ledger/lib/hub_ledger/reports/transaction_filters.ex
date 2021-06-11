defmodule HubLedger.Reports.TransactionFilters do
  use HubLedger.Reports.Filters

  def account_id(query, account_id) do
    from q in query,
      where: q.account_id == ^account_id
  end

  def entry_id(query, entry_id) when is_integer(entry_id) do
    from q in query,
      where: q.entry_id == ^entry_id
  end

  def entry_id(query, entry_ids) when is_list(entry_ids) do
    from q in query,
      where: q.entry_id in ^entry_ids
  end

  def kind(query, kind) do
    from q in query,
      where: q.kind == ^kind
  end

  def from_date(query, date) do
    from q in query,
      where: q.reported_date >= ^date
  end

  def to_date(query, date) do
    from q in query,
      where: q.reported_date <= ^date
  end

  def order_by(query, "asc") do
    from q in query,
      order_by: [asc: q.reported_date]
  end

  def order_by(query, "desc") do
    from q in query,
      order_by: [desc: q.reported_date]
  end

  def sum(query) do
    from q in query,
      select: sum(fragment("(money->>'amount')::bigint"))
  end
end
