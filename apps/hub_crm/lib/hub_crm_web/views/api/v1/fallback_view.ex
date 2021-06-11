defmodule HubCrmWeb.Api.V1.FallbackView do
  @moduledoc false
  use HubCrmWeb, :view

  def render("error.json", %{errors: errors}) do
    %{error: errors}
  end
end
