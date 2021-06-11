defmodule HubCrmWeb.Api.V1.SupportView do
  @moduledoc false
  use HubCrmWeb, :view

  alias HubCrmWeb.Api.V1.SupportView

  def render("country.json", %{support: country}) do
    %{
      Object: "Country",
      name: country.name,
      alpha_3: country.alpha_3
    }
  end

  def render("countries.json", %{countries: countries}) do
    render_many(countries, SupportView, "country.json")
  end
end
