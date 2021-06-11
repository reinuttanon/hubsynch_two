defmodule HubIdentityWeb.Api.V1.EmailController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.{Identities, Metrics, Verifications}
  alias HubIdentity.Identities.{Email, User}
  alias HubIdentity.Verifications.{EmailVerifyReference, EmailVerifyReferenceServer}

  def index(conn, %{"user_uid" => user_uid}) do
    with %User{emails: emails} <- Identities.get_user(%{uid: user_uid}) do
      render(conn, "index.json", %{emails: emails})
    end
  end

  def show(conn, %{"user_uid" => user_uid, "uid" => uid}) do
    with %Email{} = email <- Identities.get_email(%{user_uid: user_uid, uid: uid}) do
      render(conn, "show.json", %{email: email})
    end
  end

  def create(conn, %{"user_uid" => user_uid, "email" => %{"address" => address}}) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         %User{id: user_id} <- Identities.get_user(%{uid: user_uid}),
         {:ok, email_verify_reference} <-
           Verifications.create_email_verify_reference(
             %{address: address, user: %{user_id: user_id}},
             client_service
           ),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify_reference.reference)
           ) do
      conn
      |> put_status(201)
      |> render("success.json", %{message: "email verification request sent"})
    end
  end

  def resend_confirmation(conn, %{"address" => address}) do
    with norm_email when is_binary(norm_email) <- normalize_email(address),
         %ClientService{uid: client_service_uid} <- get_session(conn, :client_service),
         {:ok, [%EmailVerifyReference{} = email_verify_reference]} <-
           EmailVerifyReferenceServer.get_email_verify_reference(%{
             client_service_uid: client_service_uid,
             address: norm_email
           }),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify_reference.reference)
           ) do
      conn
      |> put_status(201)
      |> render("success.json", %{message: "email verification request sent"})
    end
  end

  def change_primary_email(conn, %{
        "user_uid" => user_uid,
        "uid" => uid,
        "reference" => reference,
        "code" => code
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: user_uid}),
         {:ok, _} <- Verifications.validate_code(code, user, client_service, reference),
         %Email{} = email <- Identities.get_email(%{user_uid: user_uid, uid: uid}),
         {:ok, new_primary_email} <- Identities.change_user_primary_email(email) do
      render(conn, "show.json", %{email: new_primary_email})
    end
  end

  def change_primary_email(_conn, _params), do: {:error, :authorization_required}

  def delete(conn, %{
        "user_uid" => user_uid,
        "uid" => uid,
        "reference" => reference,
        "code" => code
      }) do
    with %ClientService{uid: client_service_uid} = client_service <-
           get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: user_uid}),
         {:ok, _} <- Verifications.validate_code(code, user, client_service, reference),
         %Email{} = email <- Identities.get_email(%{user_uid: user_uid, uid: uid}),
         {:ok, _} <- Identities.delete_email(email) do
      conn
      |> Metrics.delete_activity(email, client_service_uid)
      |> put_status(201)
      |> render("success.json", %{message: "email #{uid} deleted"})
    end
  end

  def delete(_conn, _params), do: {:error, :authorization_required}

  defp normalize_email(email) do
    String.replace(email, " ", "+", global: false)
  end
end
