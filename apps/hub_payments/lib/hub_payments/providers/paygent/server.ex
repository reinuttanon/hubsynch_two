defmodule HubPayments.Providers.Paygent.Server do
  import HubPayments.Providers.ResponseParser, only: [parse_response: 2]
  alias HubPayments.Providers.Paygent.MessageBuilder

  @cacertfile Application.get_env(:hub_vault, :paygent_cacertfile)
  @certfile Application.get_env(:hub_vault, :paygent_certfile)
  @http Application.get_env(:hub_vault, :http_module)
  @password Application.get_env(:hub_vault, :paygent_password)
  @url Application.get_env(:hub_vault, :paygent_url)

  def authorize(request_values) do
    @url
    |> MessageBuilder.build_authorization(request_values)
    |> @http.post("", headers(), options())
    |> parse_response("paygent")
  end

  defp headers do
    [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"charset", "Windows-31J"},
      {"User-Agent", "curl_php"}
    ]
  end

  defp options do
    [
      hackney: [
        ssl_options: [
          versions: [:"tlsv1.2"],
          cacertfile: @cacertfile,
          certfile: @certfile,
          password: charlist(@password)
        ]
      ]
    ]
  end

  defp charlist(password) when is_list(password), do: password

  defp charlist(password) when is_binary(password), do: String.to_charlist(password)
end
