defmodule HubPayments.Payments.Charge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "charges" do
    field :money, Money.Ecto.Map.Type
    field :owner, :map
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :settle_date, :utc_datetime
    field :uuid, :string
    field :credit_card_id, :id
    field :provider_id, :id

    timestamps()
  end

  @doc false
  def changeset(charge, attrs) do
    charge
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
