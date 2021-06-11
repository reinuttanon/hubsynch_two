defmodule HubIdentityWeb.Browser.V1.ProviderController do
  use HubIdentityWeb, :controller

  alias HubIdentity.{ClientServices, Identities, Providers}
  alias HubIdentity.ClientServices.{ApiKey, ClientService}
  alias HubIdentity.Identities.User

  import HubIdentityWeb.AuthenticationResponseHelper, only: [respond: 4]

  @doc """
  Main authentication through HubIdentity

  """
  def authenticate(conn, %{
        "email" => address,
        "password" => password
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user_by_email_and_password(address, password) do
      respond(conn, user, client_service, "self")
    else
      nil -> authenticate_fail_response(conn)
    end
  end

  def providers(conn, %{"api_key" => api_key}) do
    with %ApiKey{client_service: client_service, type: "public"} <-
           ClientServices.get_api_key_by_data(api_key),
         secret <- ClientServices.create_state_secret!(client_service),
         providers <- Providers.list_oauth_providers(secret) do
      conn
      |> put_session(:client_service, client_service)
      |> put_session(:api_key, api_key)
      |> render("index.html", %{providers: providers})
    end
  end

  def providers(conn, _params) do
    authenticate_fail_response(conn)
  end

  defp authenticate_fail_response(conn) do
    with api_key when is_binary(api_key) <- get_session(conn, :api_key) do
      conn
      |> put_flash(:info, "Invalid email or password.")
      |> redirect(to: Routes.browser_v1_provider_path(conn, :providers, api_key: api_key))
    end
  end
end
