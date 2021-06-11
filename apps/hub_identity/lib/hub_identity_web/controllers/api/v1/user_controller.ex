defmodule HubIdentityWeb.Api.V1.UserController do
  @moduledoc false
  use HubIdentityWeb, :api_controller

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.{Identities, Metrics, Verifications}
  alias HubIdentity.Identities.{CurrentUser, User}
  alias HubIdentityWeb.Authentication.AccessCookiesServer

  # Public key actions
  def create(conn, %{"user" => %{"email" => address, "password" => password}}) do
    with %ClientService{} = client_service <-
           get_session(conn, :client_service),
         {:ok, email_verify} <-
           Verifications.create_email_verify_reference(
             %{
               address: address,
               password: password
             },
             client_service
           ),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify.reference)
           ) do
      render(conn, "success.json", %{message: "email verification request sent"})
    end
  end

  def create(_conn, _params), do: {:user_error, "bad request"}

  def reset_password(conn, %{"email" => address}) do
    with %ClientService{id: client_service_id} <- get_session(conn, :client_service),
         norm_address when is_binary(norm_address) <- normalize_email(address),
         %User{} = user <- Identities.get_user_by_email(norm_address, primary: true),
         {:ok, email} <- Identities.get_user_primary_email(user),
         {:ok, _} <-
           Identities.deliver_user_reset_password_instructions(
             email,
             &Routes.user_reset_password_url(conn, :edit, &1),
             client_service_id
           ) do
      conn
      |> send_resp(201, "request sent")
      |> halt()
    end
  end

  # Private key actions
  def authenticate(conn, %{"email" => address, "password" => password}) do
    with %ClientService{uid: client_service_uid} <- get_session(conn, :client_service),
         %User{} = user <- Identities.get_user_by_email_and_password(address, password),
         %CurrentUser{} = current_user <- CurrentUser.build(user, address, "HubIdentity") do
      conn
      |> Metrics.cookie_activity(user, client_service_uid)
      |> put_view(HubIdentityWeb.Api.V1.CurrentUserView)
      |> render("show.json", %{user: current_user})
    end
  end

  def authenticate(_conn, _params), do: {:error, :bad_request}

  def show(conn, %{"email" => address}) do
    with norm_email when is_binary(norm_email) <- normalize_email(address),
         %User{} = user <- Identities.get_user_by_email(norm_email) do
      render(conn, "show.json", %{user: user})
    else
      nil -> {:user_error, :user_not_found}
    end
  end

  def show(conn, %{"uid" => uid}) do
    with %User{} = user <- Identities.get_user(%{uid: uid}) do
      render(conn, "show.json", %{user: user})
    else
      nil -> {:user_error, :user_not_found}
    end
  end

  def show(_conn, _params), do: :error

  def delete(conn, %{"uid" => uid, "reference" => reference, "code" => code}) do
    with %ClientService{uid: client_service_uid} = client_service <-
           get_session(conn, :client_service),
         %User{} = user <- Identities.get_user(%{uid: uid}),
         {:ok, _} <- Verifications.validate_code(code, user, client_service, reference),
         {:ok, %{update: %User{}}} <- Identities.delete_user(user),
         :ok <- AccessCookiesServer.delete_cookies(%{uid: uid}) do
      conn
      |> Metrics.delete_activity(user, client_service_uid)
      |> send_resp(202, "successful operation")
      |> halt()
    else
      nil -> {:user_error, :user_not_found}
      {:error, message} -> {:user_error, message}
    end
  end

  def delete(_conn, _params), do: {:error, :authorization_required}

  defp normalize_email(address) do
    String.replace(address, " ", "+", global: false)
  end
end
