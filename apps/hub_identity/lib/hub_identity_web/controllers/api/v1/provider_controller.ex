defmodule HubIdentityWeb.Api.V1.ProviderController do
  use HubIdentityWeb, :api_controller

  alias HubIdentity.{ClientServices, Encryption, Identities, Metrics, Providers}
  alias HubIdentity.ClientServices.{ApiKey, ClientService}
  alias HubIdentity.Encryption
  alias HubIdentity.Identities.{User}

  @doc """
  Main authentication through HubIdentity

  """
  def authenticate(conn, %{
        "provider" => "hub_identity",
        "email" => address,
        "password" => password
      }) do
    with %ClientService{uid: client_service_uid} = client_service <-
           get_session(conn, :client_service),
         %User{} = user <- Identities.get_user_by_email_and_password(address, password),
         {:ok, email} <- Identities.get_user_primary_email(user) do
      Encryption.generate_tokens(client_service, user, email)
      |> respond(conn, client_service_uid, user)
    end
  end

  def providers(conn, _params) do
    providers =
      conn
      |> get_session(:client_service)
      |> ClientServices.create_state_secret!()
      |> Providers.list_oauth_providers()

    render(conn, "index.json", %{providers: providers})
  end

  def token(conn, %{
        "grant_type" => "refresh_token",
        "client_id" => client_service_uid,
        "client_secret" => client_secret,
        "refresh_token" => refresh_token
      }) do
    with %ApiKey{client_service: %ClientService{uid: uid}, type: type} <-
           ClientServices.get_api_key_by_data(client_secret),
         true <- type == "private",
         true <- client_service_uid == uid,
         {:ok, access_token, claims} <- Encryption.refresh_token_exchange(refresh_token) do
      render(conn, "show.json", %{access_token: access_token, claims: claims})
    end
  end

  def token(_conn, _params), do: :error

  defp respond({{:ok, access_token, _}, {:ok, refresh_token, _}}, conn, client_service_uid, user) do
    conn
    |> Metrics.token_activity(user, client_service_uid)
    |> render("show.json", %{access_token: access_token, refresh_token: refresh_token})
  end

  defp respond({:ok, access_token, claims}, conn, client_service_uid, user) do
    conn
    |> Metrics.token_activity(user, client_service_uid)
    |> render("show.json", %{access_token: access_token, claims: claims})
  end
end
