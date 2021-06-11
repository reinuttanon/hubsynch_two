defmodule HubIdentityWeb.Api.V1.UserView do
  @moduledoc false
  use HubIdentityWeb, :view
  alias HubIdentityWeb.Api.V1.EmailView

  def render("show.json", %{user: user}) do
    %{
      Object: "User",
      emails: render_many(user.emails, EmailView, "show.json"),
      uid: user.uid
    }
  end

  def render("success.json", %{message: message}) do
    %{
      ok: message
    }
  end
end
