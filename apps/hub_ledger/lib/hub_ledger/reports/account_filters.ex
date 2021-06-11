defmodule HubLedger.Reports.AccountFilters do
  use HubLedger.Reports.Filters

  import Ecto.Query, warn: false

  def active(query, boolean) do
    from q in query,
      where: q.active == ^boolean
  end

  def currency(query, currency) do
    from q in query,
      where: q.currency == ^currency
  end

  def from_date(query, date) do
    from q in query,
      where: q.inserted_at >= ^date
  end

  def kind(query, kind) do
    from q in query,
      where: q.kind == ^kind
  end

  def name(query, name) do
    like = "%#{name}%"

    from q in query,
      where: like(q.name, ^like)
  end

  def to_date(query, date) do
    from q in query,
      where: q.inserted_at <= ^date
  end

  def type(query, type) do
    from q in query,
      where: q.type == ^type
  end

  def order_by(query, "asc") do
    from q in query,
      order_by: [asc: q.inserted_at]
  end

  def order_by(query, "desc") do
    from q in query,
      order_by: [desc: q.inserted_at]
  end
end
