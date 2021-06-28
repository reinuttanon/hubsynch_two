defmodule HubPayments.Providers.SBPS.ResponseParser do
  require Logger

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, "authorization") do
    decoded = Jason.decode!(body)

    with {:ok, "OK"} <- get_tag(decoded["response"], "res_result"),
         {:ok, data} <- get_authorization_data(decoded["response"]) do
      {:ok, body, data}
    else
      {:error, message} -> {:error, message}
      {:ok, "NG"} -> {:error, "SBPS error"}
    end
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _) do
    with {:ok, "OK"} <- get_tag(body, "res_result"),
         {:ok, data} <- get_capture_data(body) do
      {:ok, body, data}
    else
      {:error, message} -> {:error, message}
      {:ok, "NG"} -> {:error, "SBPS error"}
    end
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, provider) do
    Logger.error(%{provider: provider, status_code: code, error: body})
    {:error, :authorization_fail}
  end

  def parse_response({:error, reason}, provider) do
    Logger.error(%{provider: provider, error: reason})
    {:error, :unknown_token_failure}
  end

  defp get_tag(response, tag) when is_binary(response) do
    with true <- String.contains?(response, "<#{tag}>") do
      [_ | tail] = String.split(response, "<#{tag}>", parts: 2)
      [result | _] = String.split(List.first(tail), "</#{tag}>", parts: 2)
      {:ok, result}
    else
      false -> {:error, "Tag: #{tag} not found"}
    end
  end

  defp get_authorization_data(response) do
    with {:ok, sps_transaction_id} <- get_tag(response, "res_sps_transaction_id"),
         {:ok, tracking_id} <- get_tag(response, "res_tracking_id"),
         {:ok, processing_datetime} <- get_tag(response, "res_process_date") do
      {:ok,
       %{
         sps_transaction_id: sps_transaction_id,
         tracking_id: tracking_id,
         processing_datetime: processing_datetime
       }}
    end
  end

  defp get_capture_data(response) do
    with {:ok, sps_transaction_id} <- get_tag(response, "res_sps_transaction_id"),
         {:ok, processing_datetime} <- get_tag(response, "res_process_date"),
         {:ok, res_date} <- get_tag(response, "res_date") do
      {:ok,
       %{
         sps_transaction_id: sps_transaction_id,
         res_date: res_date,
         processing_datetime: processing_datetime
       }}
    end
  end
end
