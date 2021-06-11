defmodule HubIdentityWeb.Api.V1.VerificationView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("success.json", %{message: message}) do
    %{
      ok: message
    }
  end
end
