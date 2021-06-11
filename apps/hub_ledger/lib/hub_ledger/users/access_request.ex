defmodule HubLedger.Users.AccessRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias HubLedger.Users.User

  schema "access_requests" do
    field :approved_at, :utc_datetime
    field :hub_identity_uid, :string

    belongs_to :approver, User, foreign_key: :approver_id, references: :id

    timestamps()
  end

  @doc false
  def create_changeset(access_request, attrs) do
    access_request
    |> cast(attrs, [:hub_identity_uid])
    |> validate_required([:hub_identity_uid])
  end

  def update_changeset(access_request, attrs) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    access_request
    |> cast(attrs, [:approver_id])
    |> foreign_key_constraint(:approver_id)
    |> put_change(:approved_at, now)
  end
end
