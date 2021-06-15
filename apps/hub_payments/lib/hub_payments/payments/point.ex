defmodule HubPayments.Payments.Point do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubPayments.Embeds.Owner

  schema "points" do
    field :money, Money.Ecto.Map.Type
    field :process_date, :utc_datetime
    field :reference, :string
    field :request_date, :utc_datetime
    field :settle_date, :utc_datetime
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:money, :reference])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:money])
    |> put_change(:request_date, now())
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
