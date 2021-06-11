defmodule HubIdentityWeb.Api.V1.CurrentUserView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("show.json", %{user: user}) do
    %{
      Object: "CurrentUser",
      uid: user.uid,
      email: user.email,
      authenticated_by: user.authenticated_by,
      authenticated_at: user.authenticated_at
    }
  end
end
