defmodule HubPayments.Providers.ResponseParser do
  require Logger

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, "paygent") do
    Codepagex.to_string(body, "VENDORS/MICSFT/WINDOWS/CP932")
  end

  def parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _provider),
    do: {:ok, body}

  def parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, provider) do
    Logger.error(%{provider: provider, status_code: code, error: body})
    {:error, :authorization_fail}
  end

  def parse_response({:error, reason}, provider) do
    Logger.error(%{provider: provider, error: reason})
    {:error, :unknown_token_failure}
  end
end
