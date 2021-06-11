defmodule HubIdentityWeb.Api.V1.FallbackView do
  @moduledoc false
  use HubIdentityWeb, :view

  def render("error.json", %{errors: errors}) do
    %{error: errors}
  end

  def render("error.json", %{error: message}) do
    %{error: message}
  end
end
