defmodule HubCrm.Countries.Country do
  @moduledoc false
  defstruct [
    :alpha_3,
    :alpha_2,
    :name,
    :country_code,
    :iso_3166_2,
    :region
  ]

  def build(%{
        "name" => name,
        "alpha-2" => alpha_2,
        "alpha-3" => alpha_3,
        "country-code" => country_code,
        "iso_3166-2" => iso_3166_2,
        "region" => region
      }) do
    {
      alpha_3,
      alpha_2,
      country_code,
      name,
      iso_3166_2,
      region
    }
  end

  def build([country | []]), do: build(country)

  def build({
        alpha_3,
        alpha_2,
        country_code,
        name,
        iso_3166_2,
        region
      }) do
    %__MODULE__{
      alpha_3: alpha_3,
      alpha_2: alpha_2,
      name: name,
      country_code: country_code,
      iso_3166_2: iso_3166_2,
      region: region
    }
  end

  def build(_), do: nil
end
