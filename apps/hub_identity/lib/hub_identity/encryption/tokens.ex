defmodule HubIdentity.Encryption.Tokens do
  use Guardian, otp_app: :hub_identity

  alias HubIdentity.Administration.Administrator
  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Encryption
  alias HubIdentity.Encryption.JWKCert
  alias HubIdentity.Identities.{Email, User}
  alias HubIdentity.Repo

  require Logger

  @access_time 3_600
  @refresh_time 43_200

  def access_token(%ClientService{url: url}, %Administrator{email: address} = administrator) do
    claims = %{
      aud: url,
      exp: DateTime.utc_now() |> DateTime.add(@access_time) |> DateTime.to_unix(),
      email: address
    }

    %JWKCert{kid: kid} = private_key = Encryption.current_private_key()

    opts = [
      secret_key: private_key,
      headers: %{kid: kid}
    ]

    encode_and_sign(administrator, claims, opts)
  end

  def access_token(_, _), do: {:error, :unhandled_resource_type}

  def access_token(
        %ClientService{url: url} = _client_service,
        %User{uid: uid} = user,
        %Email{address: address}
      ) do
    claims = %{
      aud: url,
      exp: DateTime.utc_now() |> DateTime.add(@access_time) |> DateTime.to_unix(),
      email: address,
      uid: uid
    }

    %JWKCert{kid: kid} = private_key = Encryption.current_private_key()

    opts = [
      secret_key: private_key,
      headers: %{kid: kid}
    ]

    encode_and_sign(user, claims, opts)
  end

  def access_token(_, _, _), do: {:error, :unhandled_resource_type}

  def refresh_token(%ClientService{url: url}, resource) do
    claims = %{
      aud: url,
      typ: "refresh",
      exp: DateTime.utc_now() |> DateTime.add(@refresh_time) |> DateTime.to_unix()
    }

    %JWKCert{kid: kid} = private_key = Encryption.current_private_key()

    opts = [
      secret_key: private_key,
      headers: %{kid: kid}
    ]

    encode_and_sign(resource, claims, opts)
  end

  def refresh_exchange(refresh_token) do
    now_timestamp = DateTime.utc_now() |> DateTime.to_unix()

    %JWKCert{kid: kid} = private_key = Encryption.current_private_key()

    opts = [
      secret_key: private_key,
      headers: %{kid: kid}
    ]

    with {:ok, %{"exp" => expired}} <- decode_and_verify(refresh_token),
         true <- expired > now_timestamp do
      exchange(refresh_token, "refresh", "access", opts)
    else
      {:error, message} ->
        Logger.info(message)
        {:error, :bad_refresh_token}
    end
  end

  def refresh_seconds, do: @refresh_time

  # Guardian callbacks

  def subject_for_token(%Administrator{email: email}, _claims) do
    {:ok, "Administrators.Administrator:#{email}"}
  end

  def subject_for_token(%User{uid: uid}, _claims) do
    {:ok, "Identities.User:#{uid}"}
  end

  def subject_for_token(_, _), do: {:error, :unhandled_resource_type}

  def resource_from_claims(%{"sub" => "Administrators.Administrator:" <> email}) do
    case Repo.get_by(Administrator, %{email: email}) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(%{"sub" => "Identities.User:" <> uid}) do
    case Repo.get_by(User, %{uid: uid}) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_), do: {:error, :unhandled_resource_type}
end
