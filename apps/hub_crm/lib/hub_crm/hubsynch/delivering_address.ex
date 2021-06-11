defmodule HubCrm.Hubsynch.DeliveringAddress do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias HubCrm.Types.ZeroDateTime

  @primary_key {:user_address_id, :id, autogenerate: true}
  @timestamps_opts [type: ZeroDateTime]
  @countries [0, 1, 48]

  schema "delivering_addresses" do
    field :address_1, :integer
    field :address_2, :string
    field :address_3, :string
    field :country, :integer
    field :default_flag, :string
    field :delivering_address_last_name, :string
    field :delivering_address_first_name, :string
    field :delivering_address_last_name_kana, :string
    field :delivering_address_first_name_kana, :string
    field :delivering_address_last_name_rome, :string
    field :delivering_address_first_name_rome, :string
    field :tel, :string
    field :user_id, :integer
    field :zip_code, :string

    timestamps(inserted_at: :create_timestamp, updated_at: :update_timestamp)
  end

  @doc false
  def changeset(delivering_address, attrs) do
    delivering_address
    |> cast(attrs, [
      :address_1,
      :address_2,
      :address_3,
      :country,
      :default_flag,
      :delivering_address_last_name,
      :delivering_address_first_name,
      :delivering_address_last_name_kana,
      :delivering_address_first_name_kana,
      :delivering_address_last_name_rome,
      :delivering_address_first_name_rome,
      :tel,
      :user_id,
      :zip_code
    ])
    |> validate_required([:user_id])
    |> full_validations()
  end

  def update_changeset(delivering_address, attrs) do
    delivering_address
    |> cast(attrs, [
      :address_1,
      :address_2,
      :address_3,
      :country,
      :default_flag,
      :delivering_address_last_name,
      :delivering_address_first_name,
      :delivering_address_last_name_kana,
      :delivering_address_first_name_kana,
      :delivering_address_last_name_rome,
      :delivering_address_first_name_rome,
      :tel,
      :zip_code
    ])
    |> full_validations()
  end

  defp full_validations(changeset) do
    changeset
    |> validate_required([:address_1, :address_2, :address_3, :country, :zip_code])
    |> validate_inclusion(:address_1, 1..47)
    |> validate_length(:address_2, max: 50)
    |> validate_length(:address_3, max: 100)
    |> validate_inclusion(:country, @countries)
    |> validate_length(:zip_code, is: 7)
  end
end
