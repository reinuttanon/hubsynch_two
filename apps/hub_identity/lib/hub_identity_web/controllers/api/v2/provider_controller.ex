defmodule HubIdentityWeb.Api.V2.ProviderController do
  use HubIdentityWeb, :api_controller

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities
  alias HubIdentity.Identities.User

  @doc """
  Main authentication through HubIdentity

  """
  def authenticate(conn, %{
        "provider" => "hub_identity",
        "email" => address,
        "password" => password
      }) do
    with %ClientService{id: _id} = client_service <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user_by_email_and_password(address, password),
         {:ok, access_token, _full_claims} <-
           HubIdentity.Encryption.Tokens.access_token(client_service, user),
         {:ok, refresh_token, _full_claims} <-
           HubIdentity.Encryption.Tokens.refresh_token(client_service, user) do
      render(conn, "show.json", %{access_token: access_token, refresh_token: refresh_token})
    end
  end
end
