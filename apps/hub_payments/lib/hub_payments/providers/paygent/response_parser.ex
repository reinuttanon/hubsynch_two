defmodule HubPayments.Providers.Paygent.ResponseParser do
  require Logger

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    %{"response" => response} = Jason.decode!(body)
    fields = String.split(response, "\r\n")

    with {:ok, %{"result" => "0"} = data} <- get_response_data(%{}, fields) do
      {:ok, response, data}
    else
      {:ok, data} -> {:error, data["response_detail"]}
    end
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
    Logger.error(%{provider: "paygent", status_code: code, error: body})

    {:error, :authorization_fail}
  end

  def parse_response({:ok, %{"response" => response}}) do
    fields = String.split(response, "\r\n")

    with {:ok, %{"result" => "0"} = data} <- get_response_data(%{}, fields) do
      {:ok, response, data}
    else
      {:ok, data} -> {:error, data["response_detail"]}
    end
  end

  def parse_response({:error, reason}) do
    Logger.error(%{provider: "paygent", error: reason})
    {:error, :unknown_token_failure}
  end

  def parse_capture_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, decoded} = Codepagex.to_string(body, "VENDORS/MICSFT/WINDOWS/CP932")
    fields = String.split(decoded, "\r\n")

    with {:ok, %{"result" => "0"} = data} <- get_response_data(%{}, fields) do
      {:ok, decoded, data}
    else
      {:ok, data} -> {:error, data["response_detail"]}
    end
  end

  def parse_capture_response({:error, reason}) do
    Logger.error(%{provider: "paygent", error: reason})
    {:error, :unknown_token_failure}
  end

  defp get_response_data(data, ["" | responses]), do: get_response_data(data, responses)

  defp get_response_data(data, [response | responses]) do
    [key, value] = String.split(response, "=", parts: 2)

    case value do
      "" ->
        get_response_data(data, responses)

      _ ->
        Map.put(data, key, value)
        |> get_response_data(responses)
    end
  end

  defp get_response_data(data, []), do: {:ok, data}
end

# "\r\nresult=0\r\npayment_id=28569257\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=wbrb6GN5ikxJdC21cmrtZOl2shaJa9858V7yKBfXzQNQAOxjEA0I3wyX345HG6fh\r\nmasked_card_number=************1881\r\ncard_valid_term=0122\r\nout_acs_html="
