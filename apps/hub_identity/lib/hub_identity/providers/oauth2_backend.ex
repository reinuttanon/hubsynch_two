defmodule HubIdentity.Providers.Oauth2Backend do
  require Logger

  alias HubIdentity.Providers.Oauth2Provider

  @http Application.get_env(:hub_identity, :http)

  def get_tokens(%Oauth2Provider{token_url: token_url} = provider) do
    @http.post(token_url, "", [{"Content-Type", "application/x-www-form-urlencoded"}])
    |> parse_response(provider)
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _provider),
    do: Jason.decode(body)

  defp parse_response({:ok, %HTTPoison.Response{status_code: code, body: body}}, %Oauth2Provider{
         name: name
       }) do
    Logger.error(%{provider: name, status_code: code, error: body})
    {:error, :token_parse_fail}
  end

  defp parse_response({:error, reason}, %Oauth2Provider{name: name}) do
    Logger.error(%{provider: name, error: reason})
    {:error, :unknown_token_failure}
  end
end
