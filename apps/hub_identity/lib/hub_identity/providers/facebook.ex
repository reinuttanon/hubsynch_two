defmodule HubIdentity.Providers.Facebook do
  alias HubIdentity.Providers.ProviderConfig

  @graph_url "https://graph.facebook.com/v9.0/me"
  @http Application.get_env(:hub_identity, :http)

  def parse_tokens(%{"access_token" => access_token}, provider_config_id) do
    with url <- build_url(access_token),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- @http.get(url),
         {:ok, data} <- Jason.decode(body) do
      build_identity_params(data, provider_config_id)
    end
  end

  def parse_delete_request(%ProviderConfig{client_secret: client_secret}, %{
        "signed_request" => signed_request
      }) do
    with [signature, payload] <- String.split(signed_request, "."),
         true <- verify_signature(client_secret, payload, signature),
         {:ok, decoded} <- Base.url_decode64(payload, padding: false),
         {:ok, %{"user_id" => reference}} <- Jason.decode(decoded) do
      {:ok, reference}
    else
      false -> {:error, :data_deletion_signature_failure}
      _ -> {:error, :data_deletion_failure}
    end
  end

  defp build_url(access_token) do
    "#{@graph_url}?fields=id,email&access_token=#{access_token}"
  end

  defp build_identity_params(%{"id" => reference, "email" => email} = details, provider_config_id) do
    {:ok,
     %{
       provider: "facebook",
       reference: reference,
       email: email,
       email_verified: false,
       details: details,
       provider_config_id: provider_config_id
     }}
  end

  defp build_identity_params(%{"id" => reference} = details, provider_config_id) do
    {:ok,
     %{
       provider: "facebook",
       reference: reference,
       details: details,
       provider_config_id: provider_config_id
     }}
  end

  defp verify_signature(secret, payload, signature) do
    {:ok, raw_sig} = Base.url_decode64(signature, padding: false)
    raw_sig == :crypto.hmac(:sha256, secret, payload)
  end
end
