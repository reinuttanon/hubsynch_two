defmodule HubIdentity.Encryption.JWKCertServer do
  @moduledoc ~S"""
  A simple GenServer implementation of a custom `Guardian.Token.Jwt.SecretFetcher`
  This is appropriate for development but should not be used in production
  due to questionable private key storage, lack of multi-node support,
  node restart durability, and public key garbage collection.
  """
  use GenServer

  require Logger

  alias HubIdentity.Encryption.JWKCert
  alias HubIdentity.MementoRepo

  @behaviour Guardian.Token.Jwt.SecretFetcher

  @min_expire_seconds 36_000
  @max_expire_seconds 86_400

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    HubIdentity.MementoRepo.create_table(JWKCert)

    with {:ok, key_1, timer_reference_1} <- generate_rsa_jwk(),
         {:ok, key_2, timer_reference_2} <- generate_rsa_jwk() do
      {:ok, %{key_1 => timer_reference_1, key_2 => timer_reference_2}}
    end
  end

  @impl Guardian.Token.Jwt.SecretFetcher
  # This will always return a valid key as a new one will be generated
  # if it does not already exist.
  def fetch_signing_secret(_mod, _opts) do
    case GenServer.call(__MODULE__, :private_key) do
      %JWKCert{private_key: private_key} -> {:ok, private_key}
      _ -> {:error, :private_key_not_found}
    end
  end

  @impl Guardian.Token.Jwt.SecretFetcher
  # This assumes that the adapter properly assigned a key id (kid)
  # to the signing key. Make sure it's there! with something like
  # JOSE.JWK.merge(jwk, %{"kid" => JOSE.JWK.thumbprint(jwk)})
  # see https://tools.ietf.org/html/rfc7515#section-4.1.4
  # for details
  def fetch_verifying_secret(_mod, %{"kid" => kid}, _opts) do
    case GenServer.call(__MODULE__, {:public_key, kid}) do
      %JOSE.JWK{} = public_key -> {:ok, public_key}
      _ -> {:error, :public_key_not_found}
    end
  end

  def current_keys do
    GenServer.call(__MODULE__, :keys)
  end

  def rotate_key(kid) do
    GenServer.call(__MODULE__, {:rotate_key, kid})
  end

  @impl true
  def handle_call(:private_key, _from, state) do
    current_key = HubIdentity.Encryption.current_private_key()
    {:reply, current_key, state}
  end

  @impl true
  def handle_call({:public_key, kid}, _from, state) do
    public_key = HubIdentity.Encryption.public_key(kid)
    {:reply, public_key, state}
  end

  @impl true
  def handle_call(:keys, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:rotate_key, kid}, _from, state) do
    with {:ok, new_state} <- rotate(kid, state) do
      Logger.info("#{kid} rotated")

      {:reply, {:ok, "#{kid} rotated"}, new_state}
    end
  end

  @impl true
  def handle_info({:rotate_key, kid}, state) do
    with {:ok, new_state} <- rotate(kid, state) do
      Logger.info("#{kid} rotated")

      {:noreply, new_state}
    end
  end

  defp generate_rsa_jwk do
    seconds = Enum.random(@min_expire_seconds..@max_expire_seconds)

    expires =
      DateTime.utc_now()
      |> DateTime.add(seconds, :second)
      |> DateTime.to_unix()

    delete_seconds = HubIdentity.Encryption.Tokens.refresh_seconds() + seconds

    with %JWKCert{kid: kid} <- build_and_save_jwk(expires),
         milliseconds <- delete_seconds * 1000,
         {:ok, timer_reference} <- :timer.send_after(milliseconds, {:rotate_key, kid}) do
      Logger.info("#{kid} generated")
      {:ok, kid, timer_reference}
    end
  end

  defp build_and_save_jwk(expires) do
    JOSE.JWK.generate_key({:rsa, 2048})
    |> JWKCert.changeset(expires)
    |> MementoRepo.insert!()
  end

  defp rotate(kid, state) do
    with {:ok, key, timer_reference} <- generate_rsa_jwk(),
         {:ok, _key} <- MementoRepo.withdraw(JWKCert, kid) do
      new_state =
        state
        |> Map.drop([kid])
        |> Map.put(key, timer_reference)

      {:ok, new_state}
    end
  end
end
