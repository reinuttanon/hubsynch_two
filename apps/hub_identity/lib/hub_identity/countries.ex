defmodule HubIdentity.Countries do
  alias HubIdentity.Countries.CountryServer

  def all do
    CountryServer.all()
  end

  def get_country_by_code(code) do
    CountryServer.get_country_by_code(code)
  end
end
