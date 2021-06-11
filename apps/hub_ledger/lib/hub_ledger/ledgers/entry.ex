defmodule HubLedger.Ledgers.Entry do
  use Ecto.Schema

  import Ecto.Changeset

  alias HubLedger.Embeds.Owner

  schema "entries" do
    field :description, :string
    field :reported_date, :utc_datetime
    field :uuid, :string

    embeds_one :owner, Owner, on_replace: :update

    has_many :transactions, HubLedger.Ledgers.Transaction

    timestamps()
  end

  @doc false
  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:description, :reported_date])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:description])
    |> default_reported_date()
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  defp default_reported_date(changeset) do
    case get_change(changeset, :reported_date) do
      nil -> put_change(changeset, :reported_date, now())
      _ -> changeset
    end
  end

  defp now do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
  end
end
