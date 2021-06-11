defmodule HubIdentity.Encryption do
  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Encryption.{JWKCert, JWKCertServer, Tokens}
  alias HubIdentity.MementoRepo

  def current_kids do
    JWKCertServer.current_keys()
    |> Map.keys()
  end

  def current_private_key do
    MementoRepo.all(JWKCert)
    |> Enum.sort(&(&1.expires >= &2.expires))
    |> hd()
  end

  def generate_tokens(%ClientService{refresh_token: false} = client_service, resource) do
    Tokens.access_token(client_service, resource)
  end

  def generate_tokens(%ClientService{refresh_token: false} = client_service, user, email) do
    Tokens.access_token(client_service, user, email)
  end

  def generate_tokens(%ClientService{} = client_service, resource) do
    access_token_task = Task.async(fn -> Tokens.access_token(client_service, resource) end)

    refresh_token_task = Task.async(fn -> Tokens.refresh_token(client_service, resource) end)

    {Task.await(access_token_task), Task.await(refresh_token_task)}
  end

  def generate_tokens(%ClientService{} = client_service, user, email) do
    access_token_task = Task.async(fn -> Tokens.access_token(client_service, user, email) end)

    refresh_token_task = Task.async(fn -> Tokens.refresh_token(client_service, user) end)

    {Task.await(access_token_task), Task.await(refresh_token_task)}
  end

  def private_key(kid) do
    with %JWKCert{private_key: private_key} <- MementoRepo.get_one(JWKCert, kid) do
      private_key
    end
  end

  def public_key(kid) do
    with %JWKCert{public_key: public_key} <- MementoRepo.get_one(JWKCert, kid) do
      public_key
    end
  end

  def public_keys do
    MementoRepo.all(JWKCert)
    |> Enum.map(fn key -> public_key_map(key) end)
  end

  def refresh_token_exchange(refresh_token) do
    with {:ok, _refresh, {access_token, access_claims}} <-
           Tokens.refresh_exchange(refresh_token) do
      {:ok, access_token, access_claims}
    end
  end

  def rotate_key(kid) do
    JWKCertServer.rotate_key(kid)
  end

  defp public_key_map(%JWKCert{kid: kid, public_key: public_key, expires: expires}) do
    {_hd, %{"e" => e, "kty" => kty, "n" => n}} = JOSE.JWK.to_public_map(public_key)

    %{
      e: e,
      kty: kty,
      n: n,
      kid: kid,
      expires: expires
    }
  end
end
