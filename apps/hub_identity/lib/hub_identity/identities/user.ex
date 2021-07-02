defmodule HubIdentity.Identities.User do
  @moduledoc """
  A user can have no password only when it's register by a oauthprovider (facebook, google, etc),
  We send the user.uid to HubSynch when the user is successfully authenticated.
  """
  use Ecto.Schema
  use HubIdentity.SoftDelete
  use HubIdentity.Uid

  import Ecto.Changeset

  alias HubIdentity.Identities.{Email, Identity}

  @derive {Inspect, except: [:password]}
  schema "users" do
    field :deleted_at, :utc_datetime
    field :hashed_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :uid, :string

    has_many :emails, Email
    has_many :identities, Identity

    timestamps()
  end

  @doc """
  A user changeset for Identity users with no login.
  This will place a random string into the password. This
  password is not able to pass the valid_password? method
  because the string is not a properly encrypted by Bcrypt.

  """
  def identity_changeset do
    hashed_password = HubIdentity.Encryption.Helpers.generate_data()

    %__MODULE__{}
    |> cast(%{hashed_password: hashed_password}, [:hashed_password])
    |> put_uid()
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  A user changeset for registration.

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
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_password(opts)
    |> put_uid()
  end

  @doc """
  A user changeset for web based registration of new users. Requires a password
  and password_confirmation to match.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def web_registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [
      :password,
      :password_confirmation
    ])
    |> validate_required([:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_password(opts)
    |> put_uid()
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  Commonly used when user changing password to verify existing password.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(
        %__MODULE__{
          hashed_password: <<36, 50, 98, 36, _::binary>> = hashed_password
        },
        password
      ) do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    generate_sha_256_hash(password) == hashed_password
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp generate_sha_256_hash(string) when is_binary(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
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

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 80)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end
end
