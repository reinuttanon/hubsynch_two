defmodule HubIdentityWeb.Api.V1.VerificationController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  alias HubIdentity.{Identities, Metrics, Verifications}
  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.Identities.User

  def create(conn, %{"uid" => uid, "reference" => reference}) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: uid}),
         :ok <- Verifications.generate_code(user, client_service, reference) do
      conn
      |> send_resp(201, "successful operation")
      |> halt()
    else
      {:error, message} -> {:user_error, message}
      nil -> {:user_error, :user_not_found}
    end
  end

  def validate(conn, %{"uid" => uid, "reference" => reference, "code" => code}) do
    with %ClientService{uid: client_service_uid} = client_service <-
           get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: uid}),
         {:ok, message} <- Verifications.validate_code(code, user, client_service, reference) do
      conn
      |> Metrics.verification_activity(user, client_service_uid)
      |> render("success.json", %{message: message})
    else
      {:error, message} -> {:user_error, message}
      nil -> {:user_error, :user_not_found}
    end
  end

  def renew(conn, %{
        "uid" => uid,
        "old_reference" => old_reference,
        "new_reference" => new_reference
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: uid}),
         :ok <- Verifications.delete_code(user, client_service, old_reference),
         :ok <- Verifications.generate_code(user, client_service, new_reference) do
      conn
      |> send_resp(201, "successful operation")
      |> halt()
    else
      {:error, message} -> {:user_error, message}
      nil -> {:user_error, :user_not_found}
    end
  end
end
