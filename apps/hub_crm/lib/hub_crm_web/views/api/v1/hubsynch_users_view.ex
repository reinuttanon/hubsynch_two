defmodule HubCrmWeb.Api.V1.HubsynchUsersView do
  @moduledoc false
  use HubCrmWeb, :view

  alias HubCrmWeb.Api.V1.HubsynchAddressView

  import HubCrm.Hubsynch.FieldDefinitions, only: [get_value: 2]

  def render("show.json", %{user: %HubCrm.Hubsynch.User{addresses: addresses} = user}) do
    %{
      Object: "User",
      birthday: user.birthday,
      blood: get_value(:blood, user.blood),
      email: user.email,
      first_name: user.first_name,
      first_name_kana: user.first_name,
      first_name_rome: user.first_name_rome,
      hashid: user.hashid,
      hybsynch_user_id: user.user_id,
      last_name: user.last_name,
      last_name_kana: user.last_name_kana,
      last_name_rome: user.last_name_rome,
      occupation: get_value(:occupation, user.occupation),
      profile_image: user.profile_image,
      sex: get_value(:gender, user.sex),
      create_timestamp: user.create_timestamp,
      update_timestamp: user.update_timestamp,
      addresses: render_many(addresses, HubsynchAddressView, "address.json")
    }
  end
end
