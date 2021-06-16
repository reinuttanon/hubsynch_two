defmodule HubLedger.Reports.EntryFilters do
  use HubLedger.Reports.Filters

  import Ecto.Query, warn: false

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
end
