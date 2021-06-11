defmodule HubPayments.Providers.Paygent.MessageBuilder do
  def build_authorization(url, %{"card_number" => vault_record_uid} = request_values) do
    # with %VaultRecord{encrypted_data: pan} <- Tokens.get_vault_record(%{uid: vault_record_uid}) do
    #   request_values
    #   |> Map.replace("card_number", pan)
    #   |> build_url(url)
    # else
    #   nil -> {:error, :invalid_vault_record}
    # end
  end

  defp build_url(request_values, url) do
    url_encoded =
      Map.to_list(request_values)
      |> url_encode()

    "#{url}?#{url_encoded}"
  end

  defp url_encode(values, encoded \\ "")

  defp url_encode([], encoded), do: encoded

  defp url_encode([{key, value} | values], "") do
    url_encode(values, "#{key}=#{value}")
  end

  defp url_encode([{key, value} | values], encoded) do
    url_encode(values, "#{encoded}&#{key}=#{value}")
  end
end
