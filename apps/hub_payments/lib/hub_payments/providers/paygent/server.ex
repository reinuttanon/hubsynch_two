defmodule HubPayments.Providers.Paygent.Server do
  alias HubPayments.Providers.Paygent.{MessageBuilder, ResponseParser}

  @cacertfile Application.get_env(:hub_vault, :paygent_cacertfile)
  @certfile Application.get_env(:hub_vault, :paygent_certfile)
  # @http Application.get_env(:hub_vault, :http_module)
  @http Application.get_env(:hub_payments, :http_module)
  @password Application.get_env(:hub_vault, :paygent_password)
  @url Application.get_env(:hub_vault, :paygent_url)

  def capture(message) do
    "#{@url}?#{message}"
    |> @http.post("", headers(), options())
    |> ResponseParser.parse_capture_response()
  end

  defp headers do
    [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"charset", "Windows-31J"},
      {"User-Agent", "curl_php"}
    ]
  end

  defp options do
    cacertfile = Path.expand("../../../../#{@cacertfile}", __DIR__)
    certfile = Path.expand("../../../../#{@certfile}", __DIR__)

    [
      hackney: [
        ssl_options: [
          versions: [:"tlsv1.2"],
          cacertfile: cacertfile,
          certfile: certfile,
          password: charlist(@password)
        ]
      ]
    ]
  end

  defp charlist(password) when is_list(password), do: password

  defp charlist(password) when is_binary(password), do: String.to_charlist(password)
end
