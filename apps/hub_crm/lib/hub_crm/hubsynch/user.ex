defmodule HubCrm.Hubsynch.User do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias HubCrm.Types.ZeroDate
  alias HubCrm.Types.ZeroDateTime

  @primary_key {:user_id, :id, autogenerate: true}
  @blood_types [1, 2, 3, 4, 5]
  @countries [0, 1, 48]
  @sexes [1, 2, 3]
  @timestamps_opts [type: ZeroDateTime]

  schema "users" do
    field :activate_flag, :string, default: "false"
    field :address_1, :integer
    field :address_2, :string
    field :address_3, :string
    field :birthday, ZeroDate
    field :blood, :integer
    field :country, :integer
    field :delete_flag, :string, default: "false"
    field :email, :string
    field :first_name, :string
    field :first_name_kana, :string
    field :first_name_rome, :string
    field :hashid, :string
    field :last_name, :string
    field :last_name_kana, :string
    field :last_name_rome, :string
    field :occupation, :integer
    field :password, :string
    field :profile_image, :string
    field :sex, :integer
    field :tel, :string
    field :zip_code, :string
    field :company_app_id, :integer, virtual: true
    field :addresses, {:array, :map}, virtual: true, default: []
    field :telephones, {:array, :map}, virtual: true, default: []
    # field :restore_code, :string
    field :activate_code, :string
    # field :auth_code, :string
    # field :auth_code_expired_datetime, ZeroDateTime
    # field :activate_code_expire_timestamp, ZeroDateTime
    # field :restore_code_expired_datetime, ZeroDateTime

    timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :birthday,
      :blood,
      :email,
      :first_name,
      :first_name_kana,
      :first_name_rome,
      :last_name,
      :last_name_kana,
      :last_name_rome,
      :occupation,
      :profile_image,
      :sex,
      :company_app_id
    ])
    |> validate_required([:email])
    |> validate_length(:first_name, max: 100)
    |> validate_length(:last_name, max: 100)
    |> validate_inclusion(:blood, @blood_types)
    |> validate_inclusion(:sex, @sexes)
    |> put_hashid()

    # |> put_activate_code()
    # |> hash_password()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :birthday,
      :blood,
      :first_name,
      :first_name_kana,
      :first_name_rome,
      :last_name,
      :last_name_kana,
      :last_name_rome,
      :occupation,
      :profile_image,
      :sex
    ])
    |> validate_length(:first_name, max: 100)
    |> validate_length(:last_name, max: 100)
    |> validate_inclusion(:sex, @sexes)
  end

  def delete_changeset(user) do
    user
    |> cast(%{delete_flag: "true"}, [:delete_flag])

    # add timestamps to email field?
  end

  def address_update_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :address_1,
      :address_2,
      :address_3,
      :country,
      :tel,
      :zip_code
    ])
    |> validate_required([:country, :zip_code])
    |> validate_inclusion(:address_1, 1..47)
    |> validate_length(:address_2, max: 50)
    |> validate_length(:address_3, max: 100)
    |> validate_inclusion(:country, @countries)
    |> validate_length(:zip_code, is: 7)
  end

  def valid_password?(%__MODULE__{password: hashed_password}, password) do
    generate_hash(password) == hashed_password
  end

  def valid_password?(_, _), do: false

  def generate_hash(string) when is_binary(string) do
    :crypto.hash(:sha256, string)
    |> Base.encode16()
    |> String.downcase()
  end

  # defp hash_password(%Ecto.Changeset{valid?: true} = changeset) do
  #   with {:ok, password} <- fetch_change(changeset, :password),
  #        hashed when is_binary(hashed) <- generate_hash(password) do
  #     put_change(changeset, :password, hashed)
  #   end
  # end
  #
  # defp hash_password(changeset), do: changeset

  # defp put_activate_code(%Ecto.Changeset{valid?: true} = changeset) do
  #   with {:ok, email} <- fetch_change(changeset, :email),
  #        {:ok, company_app_id} <- fetch_change(changeset, :company_app_id) do
  #     put_change(changeset, :activate_code, generate_hash("#{email}+#{company_app_id}"))
  #   end
  # end
  #
  # defp put_activate_code(changeset), do: changeset

  defp put_hashid(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :hashid, generate_hashid())
  end

  defp put_hashid(changeset), do: changeset

  defp generate_hashid do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16()
    |> String.downcase()
    |> dashify()
  end

  defp dashify(
         <<first::binary-size(4), second::binary-size(4), third::binary-size(4),
           fourth::binary-size(4)>>
       ) do
    "#{first}-#{second}-#{third}-#{fourth}"
  end
end
