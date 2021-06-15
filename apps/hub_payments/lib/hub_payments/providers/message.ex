defmodule HubPayments.Providers.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubPayments.Embeds.Owner

  schema "messages" do
    field :data, :map, default: %{}
    field :request, :string
    field :response, :string
    field :type, :string

    belongs_to :provider, HubPayments.Providers.Provider

    embeds_one :owner, Owner, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:type, :request, :response, :data])
    |> cast_embed(:owner, with: &Owner.changeset/2)
    |> validate_required([:type, :owner, :request])
  end
end
