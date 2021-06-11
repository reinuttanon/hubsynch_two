defmodule HubCrmWeb.Api.V1.CallbackView do
  @moduledoc false
  use HubCrmWeb, :view

  def render("show.json", %{user: %HubCrm.Hubsynch.User{user_id: user_id}}) do
    %{
      "owner_uid" => "#{user_id}",
      "owner_type" => "Hubsynch.User"
    }
  end

  def render("show.json", %{user: _}) do
    %{
      "owner_uid" => "",
      "owner_type" => ""
    }
  end
end
