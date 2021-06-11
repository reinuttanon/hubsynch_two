defmodule HubIdentityWeb.Browser.V1.UserController do
  @moduledoc false
  use HubIdentityWeb, :controller

  alias HubIdentity.ClientServices.ClientService
  alias HubIdentity.{Identities, Verifications}
  alias HubIdentity.Identities.User

  import HubIdentityWeb.AuthenticationResponseHelper, only: [respond: 4]

  def new(conn, _params) do
    with %ClientService{} <- get_session(conn, :client_service) do
      changeset = User.web_registration_changeset(%User{}, %{})
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{
        "user" => %{
          "email" => address,
          "password" => password,
          "password_confirmation" => password_confirmation
        }
      }) do
    with %ClientService{} = client_service <- get_session(conn, :client_service),
         {:ok, email_verify} <-
           Verifications.create_email_verify_reference(
             %{
               address: address,
               password: password,
               password_confirmation: password_confirmation
             },
             client_service
           ),
         {:ok, _} <-
           Identities.deliver_user_confirmation_instructions(
             address,
             Routes.user_confirmation_url(conn, :confirm, email_verify.reference)
           ) do
      conn
      |> put_flash(:info, "Email verification sent")
      |> redirect(to: Routes.browser_v1_user_path(conn, :email_verification))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def email_verification(conn, _params) do
    render(conn, "email_verification.html")
  end
end
