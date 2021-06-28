defmodule HubPayments.Providers.Paygent.ResponseParser do
  require Logger

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    decoded = Jason.decode!(body)

    fields = String.split(decoded["response"], "\r\n")

    with {:ok, "success"} <- success(fields),
         {:ok, data} <- get_data(fields) do
      {:ok, decoded["response"], data}
    end
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: {:ok, body}

  def parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}) do
    Logger.error(%{provider: "paygent", status_code: code, error: body})
    {:error, :authorization_fail}
  end

  def parse_response({:ok, %{"response" => response}}) do
    fields = String.split(response, "\r\n")

    with {:ok, "success"} <- success(fields),
         {:ok, data} <- get_data(fields) do
      {:ok, response, data}
    end
  end

  def parse_response({:error, reason}) do
    Logger.error(%{provider: "paygent", error: reason})
    {:error, :unknown_token_failure}
  end

  def parse_capture_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, decoded} = Codepagex.to_string(body, "VENDORS/MICSFT/WINDOWS/CP932")

    fields = String.split(decoded, "\r\n")

    with {:ok, "success"} <- success(fields),
         {:ok, data} <- get_data(fields) do
      {:ok, decoded, data}
    end
  end

  def parse_capture_response({:error, reason}) do
    Logger.error(%{provider: "paygent", error: reason})
    {:error, :unknown_token_failure}
  end

  def success([]), do: false

  def success(["result=0" | _tail]), do: {:ok, "success"}

  def success(["result=1" | _tail]), do: {:error, "failure result 1"}

  def success(["result=7" | _tail]), do: {:error, "3d secure required"}

  def success([_hd | tail]), do: success(tail)

  def get_data([]), do: {:error, "no payment id"}

  def get_data([
        <<112, 97, 121, 109, 101, 110, 116, 95, 105, 100, 61, payment_id::binary>> | _tail
      ]),
      do: {:ok, %{payment_id: payment_id}}

  def get_data([_hd | tail]), do: get_data(tail)
end

# "\r\nresult=0\r\npayment_id=28569257\r\ntrading_id=\r\nissur_class=1\r\nacq_id=50001\r\nacq_name=NICOS\r\nissur_name=ﾋﾞｻﾞ\r\nfc_auth_umu=\r\ndaiko_code=\r\ncard_shu_code=\r\nk_card_name=\r\nissur_id=\r\nattempt_kbn=\r\nfingerprint=wbrb6GN5ikxJdC21cmrtZOl2shaJa9858V7yKBfXzQNQAOxjEA0I3wyX345HG6fh\r\nmasked_card_number=************1881\r\ncard_valid_term=0122\r\nout_acs_html="
