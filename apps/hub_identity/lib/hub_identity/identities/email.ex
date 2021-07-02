defmodule HubIdentity.Identities.Email do
  @moduledoc """
  The Emails of a user.A user must have only one primary email,
  and all email must be confirmed.
  Primary email can't be deleted.
  """
  use Ecto.Schema
  use HubIdentity.Uid

  import Ecto.Changeset
  alias HubIdentity.Identities.User

  schema "emails" do
    field :address, :string
    field :confirmed_at, :utc_datetime
    field :primary, :boolean, default: false
    field :uid, :string

    belongs_to :user, User

    timestamps()
  end

  @doc """
  Verifies if the email address is valid.
  """
  def verify_address(email, attrs) do
    email
    |> cast(attrs, [:address])
    |> validate_address()
  end

  @doc """
  A email changeset for Identity email.
  This will check if the email address is valid and unique.

  """
  def confirmed_changeset(email, attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    email
    |> cast(attrs, [:address, :primary, :user_id])
    |> validate_address()
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
    |> put_change(:confirmed_at, now)
    |> put_uid()
  end

  @doc """
  Makes the email primary by setting `primary` to true.
  """
  def primary_changeset(%__MODULE__{confirmed_at: nil} = email, _attrs) do
    email
    |> change(primary: false)
    |> add_error(:confirmation, "email must be confirmed")
  end

  def primary_changeset(email, attrs) do
    email
    |> cast(attrs, [:primary])
  end

  defp validate_address(changeset) do
    changeset
    |> validate_required([:address])
    |> validate_format(:address, ~r/^[^\s]+@[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:address, max: 160)
    |> unsafe_validate_unique(:address, HubIdentity.Repo)
    |> unique_constraint(:address)
  end
end
