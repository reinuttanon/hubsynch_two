defmodule HubIdentity.Administration.Administrator do
  @moduledoc """
  Module to handle Administrator.
  """
  use Ecto.Schema
  use HubIdentity.SoftDelete

  alias HubIdentity.ClientServices.ClientService

  import Ecto.Changeset
  import HubIdentity.Encryption.Helpers, only: [generate_data: 0]

  @derive {Inspect, except: [:password]}
  schema "administrators" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :system, :boolean, default: false
    field :confirmed_at, :naive_datetime
    field :deleted_at, :utc_datetime

    many_to_many :client_services, ClientService, join_through: "administrators_client_services"

    timestamps()
  end

  @doc """
  A administrator changeset for registration.  This is currently only
  being used with seeds and initial setup. The main way to add a new
  administrator is through the new_changeset

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(administrator, attrs, opts \\ []) do
    administrator
    |> cast(attrs, [:email, :password, :system])
    |> validate_email()
    |> validate_password(opts)
  end

  def change_administrator(administrator, attrs) do
    administrator
    |> cast(attrs, [:email, :system])
    |> validate_email()
  end

  def new_administrator(administrator, attrs) do
    administrator
    |> cast(attrs, [:email, :system])
    |> validate_email()
    |> put_change(:hashed_password, generate_data())
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, HubIdentity.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 80)
    |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A administrator changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(administrator, attrs) do
    administrator
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A administrator changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(administrator, attrs, opts \\ []) do
    administrator
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(administrator) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(administrator, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no administrator or the administrator doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(
        %HubIdentity.Administration.Administrator{hashed_password: hashed_password},
        password
      )
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
