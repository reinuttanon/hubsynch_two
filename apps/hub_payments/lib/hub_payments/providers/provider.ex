defmodule HubPayments.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  schema "providers" do
    field :active, :boolean, default: false
    field :credentials, :map, default: %{}
    field :name, :string
    field :url, :string
    field :uuid, :string

    timestamps()
  end

  @doc false
  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [:name, :credentials, :url])
    |> validate_required([:name, :credentials, :url])
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(provider, attrs) do
    provider
    |> cast(attrs, [:active, :name, :credentials, :url])
    |> validate_required([:name, :credentials, :url])
  end
end
