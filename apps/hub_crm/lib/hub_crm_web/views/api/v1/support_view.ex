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

  def render("occupation.json", %{support: {code, name}}) do
    %{
      Object: "Occupation",
      code: code,
      name: name
    }
  end

  def render("occupations.json", %{occupations: occupations}) do
    render_many(occupations, SupportView, "occupation.json")
  end

  def render("prefecture.json", %{support: {code, name}}) do
    %{
      Object: "Prefecture",
      code: code,
      name: name
    }
  end

  def render("prefectures.json", %{prefectures: prefectures}) do
    render_many(prefectures, SupportView, "prefecture.json")
  end
end
