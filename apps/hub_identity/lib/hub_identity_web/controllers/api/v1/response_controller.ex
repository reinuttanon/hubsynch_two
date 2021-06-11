defmodule HubIdentityWeb.Api.V1.ResponseController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  require Logger

  alias HubIdentity.{ClientServices, Identities, Providers, Verifications}
  alias HubIdentity.ClientServices.{ClientService, StateSecret}
  alias HubIdentity.Providers.{Oauth2Provider, ProviderConfig}

  import HubIdentityWeb.AuthenticationResponseHelper, only: [respond: 4]

  def response(conn, %{"provider" => provider_name, "code" => code, "state" => secret}) do
    with {%StateSecret{owner: %ClientService{} = client_service}, %Oauth2Provider{} = provider} <-
           async_state_secret_provider(secret, provider_name),
         {:ok, identity_params} <- Providers.fetch_and_parse_tokens(provider, code) do
      Identities.find_or_create_user_from_identity(identity_params)
      |> generate_response(conn, client_service, provider_name)
    end
  end

  def response(conn, %{"provider" => provider} = provider_info) do
    Logger.info(%{provider: provider, provider_info: provider_info})

    conn
    |> send_resp(200, "ok")
    |> halt()
  end

  def delete_data_request(conn, %{"provider" => "facebook"} = provider_info) do
    with %ProviderConfig{} = provider_config <- Providers.get_provider_config_by_name("facebook"),
         {:ok, reference} <- Providers.parse_delete_request(provider_config, provider_info),
         {:ok, data_deletion} <-
           Identities.delete_user_data(provider_config, reference) do
      render(conn, "facebook_delete_confirmation.json", %{
        url: Routes.public_users_url(conn, :data_delete_confirmation, data_deletion.uid),
        data_deletion: data_deletion
      })
    end
  end

  defp async_state_secret_provider(secret, provider_name) do
    state_task = Task.async(fn -> ClientServices.withdraw_state_secret(secret) end)
    provider_task = Task.async(fn -> Providers.get_provider_by_name(provider_name) end)
    {Task.await(state_task), Task.await(provider_task)}
  end

  defp generate_response({:ok, create_map}, conn, client_service, provider_name) do
    respond(conn, create_map, client_service, provider_name)
  end

  defp generate_response(
         {:verify_email, %{provider_info: %{email: address} = provider_info, user: user}},
         conn,
         client_service,
         provider_name
       ) do
    with {:ok, email_verify} <-
           Verifications.create_email_verify_reference(
             %{
               address: address,
               provider_info: provider_info
             },
             client_service
           ),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify.reference)
           ) do
      respond(conn, %{user: user, address: address}, client_service, provider_name)
    end
  end

  defp generate_response(
         {:verify_email, %{email: address} = provider_info},
         conn,
         %ClientService{email_confirmation_redirect_url: email_confirmation_redirect_url} =
           client_service,
         _provider_name
       ) do
    with {:ok, email_verify} <-
           Verifications.create_email_verify_reference(
             %{
               address: address,
               provider_info: provider_info
             },
             client_service
           ),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify.reference)
           ) do
      conn
      |> redirect(
        external:
          "#{email_confirmation_redirect_url}?email_verification_sent=true&email=#{address}"
      )
      |> halt()
    end
  end
end
