defmodule HubIdentity.Providers.Google do
  alias HubIdentity.Providers.GoogleCertsServer

  def parse_tokens(%{"id_token" => token}, provider_config_id) do
    with [header, claims, signature] <- String.split(token, "."),
         {:ok, identity_params} <- build_identity_params(claims, provider_config_id),
         true <- verify_signature({header, claims}, signature) do
      {:ok, identity_params}
    else
      false -> {:error, :signature_fail}
    end
  end

  defp base_jason_decode(string) do
    with {:ok, base_decoded} <- Base.url_decode64(string, padding: false),
         {:ok, jason_decoded} <- Jason.decode(base_decoded) do
      {:ok, jason_decoded}
    end
  end

  defp build_identity_params(claims, provider_config_id) do
    with {:ok, %{"email" => email, "sub" => reference} = details} <- base_jason_decode(claims) do
      {:ok,
       %{
         details: details,
         email: email,
         email_verified: details["email_verified"],
         provider: "google",
         provider_config_id: provider_config_id,
         reference: reference
       }}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp verify_signature({header, claims}, signature) do
    with {:ok, %{"kid" => key_id}} <- base_jason_decode(header),
         {:ok, decoded_signature} <- Base.url_decode64(signature, padding: false),
         {_id, e, n} <- GoogleCertsServer.get_key(key_id) do
      :crypto.verify(:rsa, :sha256, "#{header}.#{claims}", decoded_signature, [e, n])
    end
  end
end

# Google Token claims Apr 01, 2021
# %{
#   "at_hash" => "L8bzcdp5jjT2WqLb3bp9MQ",
#   "aud" => "221324018211-ustgqn7upord8ru5pbtnmj8u03dgd994.apps.googleusercontent.com",
#   "azp" => "221324018211-ustgqn7upord8ru5pbtnmj8u03dgd994.apps.googleusercontent.com",
#   "email" => "erin@hivelocity.co.jp",
#   "email_verified" => true,
#   "exp" => 1611189611,
#   "hd" => "hivelocity.co.jp",
#   "iat" => 1611186011,
#   "iss" => "https://accounts.google.com",
#   "sub" => "105374681595972189362"
# }
