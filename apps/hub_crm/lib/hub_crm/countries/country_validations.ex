defmodule HubCrm.Countries.CountryValidations do
  defmacro __using__(_opts) do
    quote do
      def valid_country?("UNK"), do: true

      def valid_country?(code) when is_binary(code) do
        case HubCrm.Countries.get_country_by_code(code) do
          %HubCrm.Countries.Country{} -> true
          _ -> false
        end
      end

      def valid_country?(_), do: false

      defp validate_country(changeset) do
        with {_, country} <- Ecto.Changeset.fetch_field(changeset, :country),
             true <- valid_country?(country) do
          changeset
        else
          _ -> Ecto.Changeset.add_error(changeset, :country, "country is invalid")
        end
      end
    end
  end
end
