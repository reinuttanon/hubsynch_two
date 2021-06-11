defmodule HubPayments.Payments.Point do
  use Ecto.Schema
  import Ecto.Changeset

  schema "points" do
    field :money, Money.Ecto.Map.Type
    field :owner, :map
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :settle_date, :utc_datetime
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:reference, :request_date, :process_date, :settle_date, :money, :uuid, :owner])
    |> validate_required([
      :reference,
      :request_date,
      :process_date,
      :settle_date,
      :money,
      :uuid,
      :owner
    ])
  end
end
