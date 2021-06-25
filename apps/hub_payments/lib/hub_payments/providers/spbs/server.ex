defmodule HubPayments.Providers.SBPS.Server do
  import HubPayments.Providers.SBPS.ResponseParser, only: [parse_response: 2]
  alias HubPayments.Providers.SBPS.MessageBuilder

  @basic_id Application.get_env(:hub_payments, :sbps_basic_id)
  @hash_key Application.get_env(:hub_payments, :sbps_hash_key)
  @http Application.get_env(:hub_payments, :http_module)
  @url Application.get_env(:hub_payments, :sbps_url)

  def authorize(request_values) do
    body = MessageBuilder.build_authorization(request_values)

    @http.post(@url, body, headers(), options())
    |> parse_response("SBPS")
  end

  defp headers do
    [
      {"Content-type", "text/xml; charset=Shift_JIS"},
      {"Pragma", "no-cache"},
      {"Cache-Control", "no-store, no-cache, must-revalidate"},
      {"Cache-Control", "post-check=0, pre-check=0"},
      {"Expires", "Thu, 01 Dec 1994 16:00:00 GMT"}
    ]
  end

  defp options do
    [hackney: [basic_auth: {@basic_id, @hash_key}]]
  end
end
