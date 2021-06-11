defmodule HubCrm.Hubsynch.Address do
  alias HubCrm.Hubsynch.{DeliveringAddress, User}

  defstruct [
    :id,
    :address_1,
    :address_2,
    :address_3,
    :country,
    :create_timestamp,
    :default_flag,
    :first_name,
    :first_name_kana,
    :first_name_rome,
    :last_name,
    :last_name_kana,
    :last_name_rome,
    :tel,
    :update_timestamp,
    :user_id,
    :zip_code
  ]

  def cast(%User{} = user) do
    %__MODULE__{
      id: user.user_id,
      address_1: user.address_1,
      address_2: user.address_2,
      address_3: user.address_3,
      country: user.country,
      create_timestamp: user.create_timestamp,
      last_name: user.last_name,
      first_name: user.first_name,
      last_name_kana: user.last_name_kana,
      first_name_kana: user.first_name_kana,
      last_name_rome: user.last_name_rome,
      first_name_rome: user.first_name_rome,
      tel: user.tel,
      update_timestamp: user.update_timestamp,
      user_id: user.user_id,
      zip_code: user.zip_code
    }
  end

  def cast(%DeliveringAddress{} = delivering_address) do
    %__MODULE__{
      id: delivering_address.user_address_id,
      address_1: delivering_address.address_1,
      address_2: delivering_address.address_2,
      address_3: delivering_address.address_3,
      country: delivering_address.country,
      create_timestamp: delivering_address.create_timestamp,
      default_flag: delivering_address.default_flag,
      last_name: delivering_address.delivering_address_last_name,
      first_name: delivering_address.delivering_address_first_name,
      last_name_kana: delivering_address.delivering_address_last_name_kana,
      first_name_kana: delivering_address.delivering_address_first_name_kana,
      last_name_rome: delivering_address.delivering_address_last_name_rome,
      first_name_rome: delivering_address.delivering_address_first_name_rome,
      tel: delivering_address.tel,
      update_timestamp: delivering_address.update_timestamp,
      user_id: delivering_address.user_id,
      zip_code: delivering_address.zip_code
    }
  end

  def cast(nil), do: nil

  def update_changeset(%User{} = user, attrs) do
    User.address_update_changeset(user, attrs)
  end

  def update_changeset(%DeliveringAddress{} = delivering_address, attrs) do
    DeliveringAddress.update_changeset(delivering_address, attrs)
  end
end
