defmodule HubIdentityWeb.Api.V1.EmailView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("index.json", %{emails: emails}) do
    render_many(emails, __MODULE__, "show.json")
  end

  def render("show.json", %{email: email}) do
    %{
      Object: "Email",
      address: email.address,
      confirmed_at: email.confirmed_at,
      primary: email.primary,
      uid: email.uid
    }
  end

  def render("success.json", %{message: message}) do
    %{
      success: message
    }
  end
end
