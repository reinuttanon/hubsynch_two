defmodule HubCrmWeb.Api.V1.CallbackView do
  @moduledoc false
  use HubCrmWeb, :view

  def render("show.json", %{user: _}) do
    %{
      "owner_uid" => "",
      "owner_type" => ""
    }
  end
end
