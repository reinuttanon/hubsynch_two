defmodule HubPayments.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  schema "providers" do
    field :active, :boolean, default: false
    field :credentials, :map
    field :name, :string
    field :url, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [:name, :credentials, :url, :active, :uuid])
    |> validate_required([:name, :credentials, :url, :active, :uuid])
  end
end
