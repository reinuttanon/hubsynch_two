defmodule HubCrmWeb.Api.V2.UserView do
  use HubCrmWeb, :view
  alias HubCrmWeb.Api.V2.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      first_name: user.first_name,
      first_name_kana: user.first_name_kana,
      first_name_roman: user.first_name_roman,
      last_name: user.last_name,
      last_name_kana: user.last_name_kana,
      last_name_roman: user.last_name_roman,
      gender: user.gender,
      occupation: user.occupation,
      hub_identity_uid: user.hub_identity_uid,
      uuid: user.uuid
    }
  end
end
