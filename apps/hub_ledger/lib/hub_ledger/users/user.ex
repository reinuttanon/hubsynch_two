defmodule HubLedger.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubLedger.Users.AccessRequest

  @roles ["user", "admin"]

  schema "users" do
    field :deleted_at, :utc_datetime, default: nil
    field :role, :string, default: "user"
    field :uuid, :string
    field :hub_identity_uid, :string

    has_many :access_requests, AccessRequest, foreign_key: :approver_id, references: :id

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:hub_identity_uid])
    |> validate_required([:hub_identity_uid])
    |> unique_constraint(:hub_identity_uid)
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def create_admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:hub_identity_uid])
    |> validate_required([:hub_identity_uid])
    |> unique_constraint(:hub_identity_uid)
    |> put_change(:role, "admin")
    |> put_change(:uuid, Ecto.UUID.generate())
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:role])
    |> validate_inclusion(:role, @roles)
  end

  def delete_changeset(user) do
    user
    |> cast(%{deleted_at: DateTime.utc_now()}, [:deleted_at])
  end
end
