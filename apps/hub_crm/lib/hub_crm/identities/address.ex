defmodule HubCrm.Identities.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :address_1, :string
    field :address_2, :string
    field :address_3, :string
    field :address_4, :string
    field :address_5, :string
    field :country, :string
    field :default, :boolean, default: false
    field :postal_code, :string
    field :uuid, :string

    belongs_to :user, HubCrm.Identities.User

    timestamps()
  end

  @doc false
  def create_changeset(address, attrs) do
    address
    |> cast(attrs, [
      :address_1,
      :address_2,
      :address_3,
      :address_4,
      :address_5,
      :country,
      :postal_code,
      :default
    ])
    |> validate_required([:country, :postal_code])
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(address, attrs) do
    address
    |> cast(attrs, [
      :address_1,
      :address_2,
      :address_3,
      :address_4,
      :address_5,
      :country,
      :postal_code,
      :default
    ])
    |> validate_required([:country, :postal_code])
  end
end
