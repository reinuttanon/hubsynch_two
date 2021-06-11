defmodule HubCrm.Identities.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :first_name, :string
    field :first_name_kana, :string
    field :first_name_roman, :string
    field :gender, :string
    field :hub_identity_uid, :string
    field :last_name, :string
    field :last_name_kana, :string
    field :last_name_roman, :string
    field :occupation, :string
    field :uuid, :string

    has_many :addresses, HubCrm.Identities.Address

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :first_name_kana,
      :first_name_roman,
      :last_name,
      :last_name_kana,
      :last_name_roman,
      :gender,
      :occupation,
      :hub_identity_uid
    ])
    |> validate_required([:first_name, :last_name])
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :first_name,
      :first_name_kana,
      :first_name_roman,
      :last_name,
      :last_name_kana,
      :last_name_roman,
      :gender,
      :occupation,
      :hub_identity_uid
    ])
    |> validate_required([:first_name, :last_name])
  end
end
