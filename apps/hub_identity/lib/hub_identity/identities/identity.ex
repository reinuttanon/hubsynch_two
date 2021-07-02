defmodule HubIdentity.Identities.Identity do
  use Ecto.Schema
  use HubIdentity.Uid

  import Ecto.Changeset

  alias HubIdentity.Identities.User
  alias HubIdentity.Providers.ProviderConfig

  schema "identities" do
    field :details, :map
    field :reference, :string
    field :uid, :string

    belongs_to :user, User
    belongs_to :provider_config, ProviderConfig

    timestamps()
  end

  @doc false
  def changeset(identity, attrs) do
    identity
    |> cast(attrs, [:details, :reference, :provider_config_id, :user_id])
    |> validate_required([:reference, :provider_config_id, :user_id])
    |> foreign_key_constraint(:provider_config_id)
    |> foreign_key_constraint(:user_id)
    |> put_uid()
  end
end
